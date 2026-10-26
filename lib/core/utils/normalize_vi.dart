import 'package:diacritic/diacritic.dart';

/// Lower-cases and strips Vietnamese diacritics so "Nhạc Buồn" matches
/// "nhac buon". Also collapses whitespace.
String normalizeVi(String input) {
  final lowered = input.toLowerCase().replaceAll('đ', 'd');
  return removeDiacritics(lowered).replaceAll(RegExp(r'\s+'), ' ').trim();
}

/// Builds the text stored in `tracks.search_text`.
String buildSearchText({
  required String title,
  String? artist,
  required String fileName,
}) => normalizeVi([title, artist ?? '', fileName].join(' '));

/// Comparator for sorting display names in Vietnamese-friendly order.
int compareVi(String a, String b) {
  final c = normalizeVi(a).compareTo(normalizeVi(b));
  return c != 0 ? c : a.compareTo(b);
}
