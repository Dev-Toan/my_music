/// Extracts an 11-character YouTube video id from the common link shapes:
/// watch?v=, youtu.be/, music.youtube.com, shorts/, embed/, live/.
String? extractYoutubeId(String input) {
  final text = input.trim();
  final idPattern = RegExp(r'^[0-9A-Za-z_-]{11}$');
  if (idPattern.hasMatch(text)) return text;

  final uri = Uri.tryParse(text.startsWith('http') ? text : 'https://$text');
  if (uri == null || uri.host.isEmpty) return null;
  final host = uri.host.toLowerCase();

  String? candidate;
  if (host == 'youtu.be' || host.endsWith('.youtu.be')) {
    candidate = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
  } else if (host.endsWith('youtube.com') ||
      host.endsWith('youtube-nocookie.com')) {
    candidate = uri.queryParameters['v'];
    final segs = uri.pathSegments;
    if (candidate == null &&
        segs.length >= 2 &&
        const {'shorts', 'embed', 'live', 'v'}.contains(segs.first)) {
      candidate = segs[1];
    }
  }
  if (candidate != null && idPattern.hasMatch(candidate)) return candidate;
  return null;
}
