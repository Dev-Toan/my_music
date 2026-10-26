import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as p;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../../core/app_paths.dart';
import '../../core/audio/queue_entry.dart';
import '../../core/db/database.dart';
import '../../core/utils/filename_parser.dart';
import '../../core/utils/normalize_vi.dart';
import '../../core/utils/youtube_link.dart';
import 'youtube_audio_source.dart';

class YoutubeVideoInfo {
  const YoutubeVideoInfo({
    required this.id,
    required this.title,
    required this.author,
    required this.thumbnailUrl,
    this.duration,
  });

  final String id;
  final String title;
  final String author;
  final String thumbnailUrl;
  final Duration? duration;

  factory YoutubeVideoInfo.fromHistory(YoutubeHistoryData h) =>
      YoutubeVideoInfo(
        id: h.videoId,
        title: h.title,
        author: h.author,
        thumbnailUrl: h.thumbnailUrl,
        duration: h.durationMs == null
            ? null
            : Duration(milliseconds: h.durationMs!),
      );

  QueueEntry toStreamEntry() => QueueEntry(
    youtubeId: id,
    title: title,
    artist: author,
    album: 'YouTube',
    coverUrl: thumbnailUrl,
    durationMs: duration?.inMilliseconds,
  );
}

class DownloadCancelled implements Exception {}

/// YouTube served the first part of the audio and then refused the rest.
/// Happens when YouTube demands a "PO token" for this video, which
/// youtube_explode_dart cannot produce on a phone.
class YoutubeBlockedException implements Exception {
  @override
  String toString() =>
      'YouTube chặn tải luồng audio của video này. Thử video khác, hoặc tải '
      'file mp3 bằng công cụ khác rồi chép vào thư mục nhạc.';
}

/// Wraps youtube_explode_dart. This library reverse-engineers YouTube and
/// breaks from time to time; the fix is `flutter pub upgrade youtube_explode_dart`.
class YoutubeService {
  YoutubeService({required this.db, required this.paths});

  final AppDatabase db;
  final AppPaths paths;
  YoutubeExplode _yt = YoutubeExplode();
  final _http = http.Client();
  final _audioCache = <String, AudioOnlyStreamInfo>{};

  /// YouTube rejects ranges much larger than this.
  static const _chunk = 1024 * 1024;

  /// Parses [link], fetches the video details and records it in history.
  Future<YoutubeVideoInfo> lookup(String link) async {
    final id = extractYoutubeId(link);
    if (id == null) throw const FormatException('Link YouTube không hợp lệ');
    final video = await _withRetry(() => _yt.videos.get(id));
    final info = YoutubeVideoInfo(
      id: id,
      title: video.title,
      author: video.author,
      thumbnailUrl: video.thumbnails.highResUrl,
      duration: video.duration,
    );
    await db.upsertHistory(
      YoutubeHistoryCompanion.insert(
        videoId: id,
        title: info.title,
        author: Value(info.author),
        thumbnailUrl: info.thumbnailUrl,
        durationMs: Value(info.duration?.inMilliseconds),
      ),
    );
    return info;
  }

  /// Best audio-only stream in an MP4/AAC container (iOS cannot play
  /// WebM/Opus). Cached per video; [refresh] fetches a new manifest.
  /// Skips the watch page, which YouTube rate-limits aggressively.
  Future<AudioOnlyStreamInfo> bestAudio(
    String id, {
    bool refresh = false,
  }) async {
    final cached = _audioCache[id];
    if (!refresh && cached != null) return cached;
    final manifest = await _withRetry(
      () => _yt.videos.streamsClient.getManifest(id, requireWatchPage: false),
    );
    final mp4 = manifest.audioOnly.where(
      (s) => s.container == StreamContainer.mp4,
    );
    if (mp4.isEmpty) {
      throw StateError('Video không có luồng audio phát được trên iPhone');
    }
    return _audioCache[id] = mp4.withHighestBitrate();
  }

  /// Playable source for streaming without downloading.
  AudioSource audioSource(String id, MediaItem tag) => YoutubeAudioSource(
    videoId: id,
    totalBytes: () async => (await bestAudio(id)).size.totalBytes,
    read: readAudio,
    tag: tag,
  );

  /// Reads bytes [from, until) in bounded chunks. On a 403 the URL is
  /// refreshed once; a second 403 at the same offset means YouTube is
  /// blocking the stream and [YoutubeBlockedException] is thrown.
  Stream<List<int>> readAudio(String id, int from, int until) async* {
    var info = await bestAudio(id);
    var pos = from;
    var refreshedAt = -1;
    while (pos < until) {
      final to = min(pos + _chunk, until) - 1;
      final req = http.Request('GET', info.url)
        ..headers.addAll(YoutubeHttpClient.defaultHeaders)
        ..headers['Range'] = 'bytes=$pos-$to';
      final res = await _http.send(req);
      if (res.statusCode == 403) {
        await res.stream.drain<void>();
        if (refreshedAt == pos) throw YoutubeBlockedException();
        refreshedAt = pos;
        info = await bestAudio(id, refresh: true);
        continue;
      }
      if (res.statusCode >= 400) {
        await res.stream.drain<void>();
        throw HttpException('YouTube trả về lỗi ${res.statusCode}');
      }
      await for (final data in res.stream) {
        pos += data.length;
        yield data;
      }
    }
  }

  /// Downloads the audio into Documents/YouTube as .m4a and adds it to the
  /// library. [onProgress] receives 0..1. Throws [DownloadCancelled] if
  /// [isCancelled] turns true.
  Future<int> download(
    YoutubeVideoInfo info, {
    required void Function(double) onProgress,
    required bool Function() isCancelled,
  }) async {
    final total = (await bestAudio(info.id, refresh: true)).size.totalBytes;
    final dir = Directory(paths.youtubeDir);
    await dir.create(recursive: true);

    // Hidden temp file so a concurrent scan ignores it.
    final part = File(p.join(dir.path, '.${info.id}.part'));
    final sink = part.openWrite();
    var written = 0;
    try {
      await for (final chunk in readAudio(info.id, 0, total)) {
        if (isCancelled()) throw DownloadCancelled();
        sink.add(chunk);
        written += chunk.length;
        if (total > 0) onProgress(written / total);
      }
      await sink.close();
    } catch (_) {
      await sink.close();
      if (await part.exists()) await part.delete();
      rethrow;
    }

    var fileName = '${sanitizeFileName(info.title)}.m4a';
    if (await File(p.join(dir.path, fileName)).exists()) {
      fileName = '${sanitizeFileName(info.title)} (${info.id}).m4a';
    }
    await part.rename(p.join(dir.path, fileName));

    final coverRel = await _downloadThumbnail(info);
    final folder = await db.youtubeFolder();
    final trackId = await db.upsertTrackByPath(
      TracksCompanion.insert(
        folderId: folder.id,
        relativePath: fileName,
        fileName: fileName,
        title: info.title,
        artist: Value(info.author),
        durationMs: Value(info.duration?.inMilliseconds),
        coverPath: Value(coverRel),
        searchText: buildSearchText(
          title: info.title,
          artist: info.author,
          fileName: fileName,
        ),
        source: TrackSource.youtube,
        youtubeId: Value(info.id),
        lastSeenAt: DateTime.now(),
      ),
    );
    await db.markDownloaded(info.id, trackId);
    onProgress(1);
    return trackId;
  }

  Future<String?> _downloadThumbnail(YoutubeVideoInfo info) async {
    try {
      final res = await _http.get(Uri.parse(info.thumbnailUrl));
      if (res.statusCode != 200) return null;
      final rel = 'covers/yt_${info.id}.jpg';
      await File(p.join(paths.supportDir, rel)).writeAsBytes(res.bodyBytes);
      return rel;
    } catch (_) {
      return null;
    }
  }

  /// One retry with a fresh client: YouTube sometimes rejects a session.
  Future<T> _withRetry<T>(Future<T> Function() run) async {
    try {
      return await run();
    } on YoutubeExplodeException {
      _yt.close();
      _yt = YoutubeExplode();
      return run();
    }
  }

  void dispose() {
    _yt.close();
    _http.close();
  }
}
