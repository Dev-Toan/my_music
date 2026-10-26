/// Result of parsing a music file name such as `Sơn Tùng - Lạc Trôi.mp3`.
class ParsedName {
  const ParsedName(this.title, this.artist);
  final String title;
  final String? artist;

  @override
  bool operator ==(Object other) =>
      other is ParsedName && other.title == title && other.artist == artist;

  @override
  int get hashCode => Object.hash(title, artist);

  @override
  String toString() => 'ParsedName($title, $artist)';
}

const supportedExtensions = {'.mp3', '.m4a'};

/// Returns the file name without its extension.
String stripExtension(String fileName) {
  final dot = fileName.lastIndexOf('.');
  return dot > 0 ? fileName.substring(0, dot) : fileName;
}

/// Splits `Artist - Title` (also accepts en/em dashes). If the pattern does
/// not match, the whole base name becomes the title and artist is null.
ParsedName parseFileName(String fileName) {
  final base = stripExtension(fileName).replaceAll('_', ' ').trim();
  final match = RegExp(r'^(.+?)\s+[-–—]\s+(.+)$').firstMatch(base);
  if (match != null) {
    final artist = match.group(1)!.trim();
    final title = match.group(2)!.trim();
    if (artist.isNotEmpty && title.isNotEmpty) {
      return ParsedName(title, artist);
    }
  }
  return ParsedName(base.isEmpty ? fileName : base, null);
}

/// Makes a string safe to use as a file name on iOS/Android.
String sanitizeFileName(String name) {
  final cleaned = name
      .replaceAll(RegExp(r'[\/:*?"<>|\x00-\x1F]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  final limited = cleaned.length > 120
      ? cleaned.substring(0, 120).trim()
      : cleaned;
  return limited.isEmpty ? 'audio' : limited;
}

String formatDuration(Duration? d) {
  if (d == null) return '--:--';
  final h = d.inHours;
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return h > 0 ? '$h:$m:$s' : '$m:$s';
}
