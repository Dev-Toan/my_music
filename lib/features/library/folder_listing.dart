import '../../core/db/database.dart';
import '../../core/utils/normalize_vi.dart';

class SubfolderInfo {
  const SubfolderInfo(this.name, this.relativeDir, this.trackCount);
  final String name;
  final String relativeDir;
  final int trackCount;
}

class FolderListing {
  const FolderListing(this.subfolders, this.tracks);
  final List<SubfolderInfo> subfolders;

  /// Tracks directly inside the directory (not in subfolders), sorted.
  final List<Track> tracks;
}

/// Builds the view of directory [dir] (relative, '' for root) from the flat
/// list of tracks of one folder. Subfolders only appear if they contain
/// music somewhere below them.
FolderListing listDirectory(List<Track> all, String dir) {
  final prefix = dir.isEmpty ? '' : '$dir/';
  final counts = <String, int>{};
  final direct = <Track>[];
  for (final t in all) {
    if (!t.relativePath.startsWith(prefix)) continue;
    final rest = t.relativePath.substring(prefix.length);
    final slash = rest.indexOf('/');
    if (slash < 0) {
      direct.add(t);
    } else {
      final name = rest.substring(0, slash);
      counts[name] = (counts[name] ?? 0) + 1;
    }
  }
  final subs =
      counts.entries
          .map((e) => SubfolderInfo(e.key, '$prefix${e.key}', e.value))
          .toList()
        ..sort((a, b) => compareVi(a.name, b.name));
  direct.sort((a, b) => compareVi(a.title, b.title));
  return FolderListing(subs, direct);
}
