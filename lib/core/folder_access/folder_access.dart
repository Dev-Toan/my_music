import 'dart:io';

import 'folder_access_default.dart';
import 'folder_access_ios.dart';

/// A folder chosen by the user through the system picker.
class PickedFolder {
  const PickedFolder({
    required this.bookmark,
    required this.path,
    required this.name,
  });

  /// Persisted token. iOS: base64 security-scoped bookmark; else the path.
  final String bookmark;
  final String path;
  final String name;
}

class ResolvedFolder {
  const ResolvedFolder({required this.path, this.refreshedBookmark});

  final String path;

  /// Non-null when iOS reported the stored bookmark as stale.
  final String? refreshedBookmark;
}

/// Platform abstraction over picking folders and regaining access to them
/// on later launches.
abstract class FolderAccess {
  /// Opens the system folder picker. Returns null if the user cancelled.
  Future<PickedFolder?> pickFolder();

  /// Turns a stored bookmark back into a readable path. Access stays open
  /// until [release] is called (the app keeps it open while running).
  Future<ResolvedFolder> resolve(String bookmark);

  Future<void> release(String path);

  /// iOS: asks iCloud Drive to download a placeholder file. No-op elsewhere.
  Future<void> requestDownload(String path);

  factory FolderAccess.forPlatform() =>
      Platform.isIOS ? FolderAccessIos() : FolderAccessDefault();
}
