import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// App-owned directories. Stored paths in the DB are relative to these
/// because the iOS app container path changes between installs.
class AppPaths {
  AppPaths({required this.supportDir, required this.documentsDir});

  final String supportDir;
  final String documentsDir;

  /// Downloaded YouTube audio. Lives in Documents so it shows up in the
  /// iOS Files app under "My Music".
  String get youtubeDir => p.join(documentsDir, 'YouTube');
  String get coversDir => p.join(supportDir, 'covers');

  String? absoluteCover(String? relative) =>
      relative == null ? null : p.join(supportDir, relative);

  static Future<AppPaths> init() async {
    final support = await getApplicationSupportDirectory();
    final docs = await getApplicationDocumentsDirectory();
    final paths = AppPaths(supportDir: support.path, documentsDir: docs.path);
    await Directory(paths.youtubeDir).create(recursive: true);
    await Directory(paths.coversDir).create(recursive: true);
    return paths;
  }
}
