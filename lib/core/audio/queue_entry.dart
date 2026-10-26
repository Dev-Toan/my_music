import 'package:audio_service/audio_service.dart';

/// One item in the play queue. Local tracks reference a `tracks` row;
/// YouTube streams that were never downloaded only carry the video id.
///
/// [filePath] is transient (not persisted) because the iOS container path
/// changes between installs.
class QueueEntry {
  const QueueEntry({
    this.trackId,
    this.youtubeId,
    required this.title,
    this.artist,
    this.album,
    this.coverFile,
    this.coverUrl,
    this.durationMs,
    this.filePath,
  }) : assert(trackId != null || youtubeId != null);

  final int? trackId;
  final String? youtubeId;
  final String title;
  final String? artist;

  /// Shown under the title; we use the folder name.
  final String? album;
  final String? coverFile;
  final String? coverUrl;
  final int? durationMs;
  final String? filePath;

  bool get isStream => trackId == null;
  String get id => trackId != null ? 't:$trackId' : 'y:$youtubeId';

  QueueEntry copyWith({String? filePath, int? durationMs}) => QueueEntry(
    trackId: trackId,
    youtubeId: youtubeId,
    title: title,
    artist: artist,
    album: album,
    coverFile: coverFile,
    coverUrl: coverUrl,
    durationMs: durationMs ?? this.durationMs,
    filePath: filePath ?? this.filePath,
  );

  MediaItem toMediaItem() => MediaItem(
    id: id,
    title: title,
    artist: artist,
    album: album,
    duration: durationMs == null ? null : Duration(milliseconds: durationMs!),
    artUri: coverFile != null
        ? Uri.file(coverFile!)
        : (coverUrl != null ? Uri.parse(coverUrl!) : null),
    extras: {'trackId': trackId, 'youtubeId': youtubeId},
  );

  Map<String, dynamic> toJson() => {
    'trackId': trackId,
    'youtubeId': youtubeId,
    'title': title,
    'artist': artist,
    'album': album,
    'coverUrl': coverUrl,
    'durationMs': durationMs,
  };

  factory QueueEntry.fromJson(Map<String, dynamic> j) => QueueEntry(
    trackId: j['trackId'] as int?,
    youtubeId: j['youtubeId'] as String?,
    title: j['title'] as String? ?? '',
    artist: j['artist'] as String?,
    album: j['album'] as String?,
    coverUrl: j['coverUrl'] as String?,
    durationMs: j['durationMs'] as int?,
  );
}

/// Pure queue helpers, kept separate so they can be unit tested without a
/// real audio player.
class QueueMath {
  /// Index at which "play next" inserts.
  static int playNextIndex(int? currentIndex, int length) =>
      currentIndex == null ? length : (currentIndex + 1).clamp(0, length);

  /// Position after seeking by [delta], clamped to [0, duration].
  static Duration clampSeek(
    Duration position,
    Duration delta,
    Duration? duration,
  ) {
    var target = position + delta;
    if (target < Duration.zero) target = Duration.zero;
    if (duration != null && target > duration) target = duration;
    return target;
  }

  /// New current index after moving an item from [from] to [to].
  static int indexAfterMove(int current, int from, int to) {
    if (from == current) return to;
    if (from < current && to >= current) return current - 1;
    if (from > current && to <= current) return current + 1;
    return current;
  }
}
