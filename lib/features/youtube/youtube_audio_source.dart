// StreamAudioSource is marked experimental in just_audio but is the only way
// to feed custom bytes to the player; pin just_audio when upgrading.
// ignore_for_file: experimental_member_use

import 'dart:math';

import 'package:just_audio/just_audio.dart';

/// Reads bytes [from, until) of a video's audio stream.
typedef AudioRangeReader = Stream<List<int>> Function(
  String videoId,
  int from,
  int until,
);

/// Feeds a YouTube audio stream to just_audio through its local proxy.
///
/// Opening the stream URL directly gets HTTP 403: YouTube only serves it in
/// bounded byte ranges with browser-like headers, so the actual requests are
/// made by [YoutubeService.readAudio].
class YoutubeAudioSource extends StreamAudioSource {
  YoutubeAudioSource({
    required this.videoId,
    required this.totalBytes,
    required this.read,
    super.tag,
  });

  final String videoId;
  final Future<int> Function() totalBytes;
  final AudioRangeReader read;

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    final total = await totalBytes();
    final from = start ?? 0;
    final until = min(end ?? total, total); // exclusive
    return StreamAudioResponse(
      sourceLength: total,
      contentLength: max(0, until - from),
      offset: from,
      stream: read(videoId, from, until),
      contentType: 'audio/mp4',
    );
  }
}
