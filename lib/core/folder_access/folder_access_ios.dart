import 'package:flutter/services.dart';

import 'folder_access.dart';

/// iOS: talks to `FolderPickerPlugin` in ios/Runner/AppDelegate.swift, which
/// wraps UIDocumentPickerViewController and security-scoped bookmarks.
class FolderAccessIos implements FolderAccess {
  static const _channel = MethodChannel('my_music/folder');

  @override
  Future<PickedFolder?> pickFolder() async {
    final result = await _channel.invokeMapMethod<String, dynamic>(
      'pickFolder',
    );
    if (result == null) return null;
    return PickedFolder(
      bookmark: result['bookmark'] as String,
      path: result['path'] as String,
      name: result['name'] as String,
    );
  }

  @override
  Future<ResolvedFolder> resolve(String bookmark) async {
    final result = await _channel.invokeMapMethod<String, dynamic>('resolve', {
      'bookmark': bookmark,
    });
    return ResolvedFolder(
      path: result!['path'] as String,
      refreshedBookmark: result['bookmark'] as String?,
    );
  }

  @override
  Future<void> release(String path) =>
      _channel.invokeMethod('release', {'path': path});

  @override
  Future<void> requestDownload(String path) =>
      _channel.invokeMethod('requestDownload', {'path': path});
}
