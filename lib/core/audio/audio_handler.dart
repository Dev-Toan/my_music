import 'dart:async';
import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import 'queue_entry.dart';

/// Builds the source for a YouTube video that is streamed, not downloaded.
typedef StreamSourceFactory = AudioSource Function(
  String videoId,
  MediaItem tag,
);

/// Refreshes persisted entries on restore: fills in file paths and current
/// metadata for local tracks and drops tracks that no longer exist.
typedef EntryRefresher = Future<List<QueueEntry>> Function(List<QueueEntry>);

const seekStep = Duration(seconds: 5);

/// The only place that talks to just_audio. Exposed to the OS through
/// audio_service (lock screen, Control Center, headset buttons).
class MyAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  MyAudioHandler({required this.streamSource, required this.persist}) {
    _player.playbackEventStream.listen(
      (_) => _broadcast(),
      onError: (Object e, StackTrace st) {
        final i = _currentIndex;
        final isStream =
            i != null && i < _entries.length && _entries[i].isStream;
        _errors.add(
          isStream
              ? 'Không phát được video YouTube này. YouTube có thể đang chặn '
                    'luồng audio của nó.'
              : 'Không phát được: $e',
        );
        _broadcast();
      },
    );
    _player.playingStream.listen((playing) {
      _broadcast();
      if (!playing) unawaited(_save());
    });
    _player.currentIndexStream.listen(_onIndexChanged);
    _player.durationStream.listen(_onDuration);
    _player.processingStateStream.listen((s) {
      if (s == ProcessingState.completed) unawaited(_onCompleted());
    });
    _persistTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_player.playing) unawaited(_save());
    });
    unawaited(_configureSession());
  }

  final StreamSourceFactory streamSource;
  final Future<void> Function(String json) persist;

  /// handleInterruptions is off: we pause on interruptions ourselves and,
  /// by design, never auto-resume (the user only wants playback on tap).
  final _player = AudioPlayer(handleInterruptions: false);
  final _errors = StreamController<String>.broadcast();
  late final Timer _persistTimer;

  List<QueueEntry> _entries = [];

  /// False when [_entries] has not been handed to the player yet (after a
  /// restore that contains an unresolved YouTube stream).
  bool _loaded = false;
  int _pendingIndex = 0;
  Duration _pendingPosition = Duration.zero;
  AudioServiceRepeatMode _repeat = AudioServiceRepeatMode.none;
  bool _ducked = false;

  /// Off until the saved session has been restored, so the player's initial
  /// events cannot overwrite the saved state with an empty queue.
  bool _persistEnabled = false;

  /// True while setAudioSources runs; just_audio briefly reports index 0
  /// before jumping to initialIndex, which would show the wrong title.
  bool _settingSources = false;

  /// Human-readable errors for the UI to show as snack bars.
  Stream<String> get errors => _errors.stream;
  List<QueueEntry> get entries => List.unmodifiable(_entries);
  Stream<Duration> get positionStream => _player.positionStream;
  Duration get position => _loaded ? _player.position : _pendingPosition;

  Future<void> _configureSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    session.interruptionEventStream.listen((event) {
      if (event.begin) {
        if (event.type == AudioInterruptionType.duck) {
          _ducked = true;
          _player.setVolume(0.3);
        } else {
          pause();
        }
      } else if (_ducked) {
        _ducked = false;
        _player.setVolume(1.0);
      }
      // Interruption ended (call, Siri, alarm): stay paused on purpose.
    });
    // Headphones unplugged / Bluetooth disconnected -> pause.
    // Nothing is done when headphones connect (explicit anti-goal).
    session.becomingNoisyEventStream.listen((_) => pause());
  }

  // ---------------- public API used by the UI ----------------

  /// Replaces the queue with [list] and starts playing at [index].
  Future<void> playEntries(List<QueueEntry> list, int index) async {
    if (list.isEmpty) return;
    _persistEnabled = true;
    _entries = List.of(list);
    _publishQueue();
    mediaItem.add(_entries[index].toMediaItem());
    _pendingIndex = index;
    _pendingPosition = Duration.zero;
    _loaded = false;
    if (await _load()) {
      unawaited(_player.play());
    }
    await _save();
  }

  /// Inserts [entry] right after the current item.
  Future<void> playNext(QueueEntry entry) async {
    if (_entries.isEmpty) return playEntries([entry], 0);
    final at = QueueMath.playNextIndex(_currentIndex, _entries.length);
    try {
      _entries.insert(at, entry);
      if (_loaded) await _player.insertAudioSource(at, _sourceFor(entry));
    } catch (err) {
      _errors.add('Không thêm được vào hàng đợi: $err');
      return;
    }
    if (!_loaded && at <= _pendingIndex) _pendingIndex++;
    _publishQueue();
    await _save();
  }

  Future<void> moveQueueItem(int from, int to) async {
    if (from == to) return;
    final e = _entries.removeAt(from);
    _entries.insert(to, e);
    if (_loaded) {
      await _player.moveAudioSource(from, to);
    } else {
      _pendingIndex = QueueMath.indexAfterMove(_pendingIndex, from, to);
    }
    _publishQueue();
    _broadcast();
    await _save();
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    if (index < 0 || index >= _entries.length) return;
    if (_entries.length == 1) {
      await _player.stop();
      await _player.clearAudioSources();
      _entries = [];
      _loaded = false;
      _pendingIndex = 0;
      _pendingPosition = Duration.zero;
      queue.add([]);
      mediaItem.add(null);
      _broadcast();
      await _save();
      return;
    }
    _entries.removeAt(index);
    if (_loaded) {
      await _player.removeAudioSourceAt(index);
    } else if (index < _pendingIndex || _pendingIndex >= _entries.length) {
      _pendingIndex = (_pendingIndex - 1).clamp(0, _entries.length - 1);
    }
    _publishQueue();
    _onIndexChanged(_currentIndex);
    await _save();
  }

  /// Restores the last session paused at the saved position. Never plays.
  Future<void> restore(String json, EntryRefresher refresh) async {
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      final saved = (map['entries'] as List)
          .map((e) => QueueEntry.fromJson(e as Map<String, dynamic>))
          .toList();
      final savedIndex = map['index'] as int? ?? 0;
      final currentId = savedIndex < saved.length ? saved[savedIndex].id : null;
      _repeat = AudioServiceRepeatMode.values.byName(
        map['repeat'] as String? ?? 'none',
      );
      await _player.setLoopMode(_loopModeFor(_repeat));

      final fresh = await refresh(saved);
      if (fresh.isEmpty) {
        _broadcast();
        return;
      }
      var index = fresh.indexWhere((e) => e.id == currentId);
      var position = Duration(milliseconds: map['positionMs'] as int? ?? 0);
      if (index < 0) {
        index = 0;
        position = Duration.zero;
      }
      // Saved at (or right before) the end of the track: start it over.
      final dur = fresh[index].durationMs;
      if (dur != null && position.inMilliseconds >= dur - 1000) {
        position = Duration.zero;
      }
      _entries = fresh;
      _pendingIndex = index;
      _pendingPosition = position;
      _publishQueue();
      mediaItem.add(_entries[index].toMediaItem());
      // Not handed to the player yet: the first play() loads the saved
      // index and position. Until then seek/skip act on the pending values.
      _broadcast();
    } catch (e, st) {
      debugPrint('restore failed: $e\n$st');
    }
  }

  // ---------------- AudioHandler overrides ----------------

  @override
  Future<void> play() async {
    if (_entries.isEmpty) return;
    if (!_loaded && !await _load()) return;
    unawaited(_player.play());
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.pause();
    await _save();
  }

  @override
  Future<void> seek(Duration position) async {
    if (_loaded) {
      await _player.seek(position);
    } else {
      _pendingPosition = position;
      _broadcast();
    }
  }

  @override
  Future<void> fastForward() => _seekBy(seekStep);

  @override
  Future<void> rewind() => _seekBy(-seekStep);

  @override
  Future<void> skipToNext() async {
    if (!_loaded) return _skipPending(1);
    if (_player.hasNext) {
      await _player.seekToNext();
    } else if (_repeat != AudioServiceRepeatMode.none && _entries.isNotEmpty) {
      await _player.seek(Duration.zero, index: 0);
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (!_loaded) return _skipPending(-1);
    if (_player.position > const Duration(seconds: 3) || !_player.hasPrevious) {
      await _player.seek(Duration.zero);
    } else {
      await _player.seekToPrevious();
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= _entries.length) return;
    if (!_loaded) {
      _pendingIndex = index;
      _pendingPosition = Duration.zero;
      _onIndexChanged(index);
      return play();
    }
    await _player.seek(Duration.zero, index: index);
    unawaited(_player.play());
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    _repeat = repeatMode;
    await _player.setLoopMode(_loopModeFor(repeatMode));
    _broadcast();
    await _save();
  }

  /// Off -> all -> one -> off.
  Future<void> cycleRepeat() => setRepeatMode(switch (_repeat) {
    AudioServiceRepeatMode.none => AudioServiceRepeatMode.all,
    AudioServiceRepeatMode.all => AudioServiceRepeatMode.one,
    AudioServiceRepeatMode.group => AudioServiceRepeatMode.one,
    AudioServiceRepeatMode.one => AudioServiceRepeatMode.none,
  });

  /// Called after the library deletes a track, so the queue does not keep
  /// pointing at a missing file.
  Future<void> removeTrackEverywhere(int trackId) async {
    for (var i = _entries.length - 1; i >= 0; i--) {
      if (_entries[i].trackId == trackId) await removeQueueItemAt(i);
    }
  }

  Future<void> dispose() async {
    _persistTimer.cancel();
    await _save();
    await _player.dispose();
  }

  // ---------------- internals ----------------

  int? get _currentIndex => _loaded ? _player.currentIndex : _pendingIndex;

  Future<bool> _load({bool preload = true}) async {
    try {
      _settingSources = true;
      try {
        await _player.setAudioSources(
          _entries.map(_sourceFor).toList(),
          initialIndex: _pendingIndex,
          initialPosition: _pendingPosition,
          preload: preload,
        );
      } finally {
        _settingSources = false;
      }
      _loaded = true;
      _onIndexChanged(_pendingIndex);
      return true;
    } catch (e) {
      _errors.add('Không mở được bài: $e');
      _loaded = false;
      _broadcast();
      return false;
    }
  }

  AudioSource _sourceFor(QueueEntry e) {
    final tag = e.toMediaItem();
    if (e.isStream) return streamSource(e.youtubeId!, tag);
    return AudioSource.file(e.filePath!, tag: tag);
  }

  Future<void> _seekBy(Duration delta) async {
    final duration = _loaded ? _player.duration : mediaItem.value?.duration;
    await seek(QueueMath.clampSeek(position, delta, duration));
  }

  void _skipPending(int delta) {
    final next = _pendingIndex + delta;
    if (next < 0 || next >= _entries.length) return;
    _pendingIndex = next;
    _pendingPosition = Duration.zero;
    _onIndexChanged(next);
    unawaited(_save());
  }

  Future<void> _onCompleted() async {
    // End of queue with repeat off: stop on the last item, keep it shown.
    await _player.pause();
    await _player.seek(Duration.zero, index: _player.currentIndex);
  }

  void _onIndexChanged(int? index) {
    if (_settingSources) return;
    if (index == null || index >= _entries.length) return;
    mediaItem.add(_entries[index].toMediaItem());
    _broadcast();
  }

  void _onDuration(Duration? d) {
    if (_settingSources) return;
    final i = _player.currentIndex;
    if (d == null || i == null || i >= _entries.length) return;
    if (_entries[i].durationMs == d.inMilliseconds) return;
    _entries[i] = _entries[i].copyWith(durationMs: d.inMilliseconds);
    _publishQueue();
    mediaItem.add(_entries[i].toMediaItem());
  }

  void _publishQueue() =>
      queue.add(_entries.map((e) => e.toMediaItem()).toList());

  void _broadcast() {
    final playing = _player.playing;
    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          playing ? MediaControl.pause : MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {MediaAction.seek},
        androidCompactActionIndices: const [0, 1, 2],
        processingState: _processingState(),
        playing: playing,
        updatePosition: position,
        bufferedPosition: _loaded ? _player.bufferedPosition : Duration.zero,
        speed: _player.speed,
        queueIndex: _currentIndex,
        repeatMode: _repeat,
      ),
    );
  }

  AudioProcessingState _processingState() {
    if (!_loaded) {
      return _entries.isEmpty
          ? AudioProcessingState.idle
          : AudioProcessingState.ready;
    }
    return switch (_player.processingState) {
      ProcessingState.idle => AudioProcessingState.idle,
      ProcessingState.loading => AudioProcessingState.loading,
      ProcessingState.buffering => AudioProcessingState.buffering,
      ProcessingState.ready => AudioProcessingState.ready,
      ProcessingState.completed => AudioProcessingState.completed,
    };
  }

  /// Call once startup restore is done (or there was nothing to restore).
  void enablePersistence() => _persistEnabled = true;

  Future<void> _save() async {
    if (!_persistEnabled) return;
    try {
      await persist(
        jsonEncode({
          'entries': _entries.map((e) => e.toJson()).toList(),
          'index': _currentIndex ?? 0,
          'positionMs': position.inMilliseconds,
          'repeat': _repeat.name,
        }),
      );
    } catch (e) {
      debugPrint('persist failed: $e');
    }
  }

  static LoopMode _loopModeFor(AudioServiceRepeatMode m) => switch (m) {
    AudioServiceRepeatMode.none => LoopMode.off,
    AudioServiceRepeatMode.one => LoopMode.one,
    AudioServiceRepeatMode.all => LoopMode.all,
    AudioServiceRepeatMode.group => LoopMode.all,
  };
}
