import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';

import 'folder_access.dart';

/// Android / desktop: plain filesystem paths.
class FolderAccessDefault implements FolderAccess {
  @override
  Future<PickedFolder?> pickFolder() async {
    if (Platform.isAndroid) {
      // READ_MEDIA_AUDIO on Android 13+, READ_EXTERNAL_STORAGE below.
      final audio = await Permission.audio.request();
      if (!audio.isGranted) await Permission.storage.request();
    }
    final path = await FilePicker.getDirectoryPath(
      dialogTitle: 'Chọn thư mục nhạc',
    );
    if (path == null) return null;
    return PickedFolder(bookmark: path, path: path, name: p.basename(path));
  }

  @override
  Future<ResolvedFolder> resolve(String bookmark) async {
    if (!await Directory(bookmark).exists()) {
      throw FileSystemException('Thư mục không còn tồn tại', bookmark);
    }
    return ResolvedFolder(path: bookmark);
  }

  @override
  Future<void> release(String path) async {}

  @override
  Future<void> requestDownload(String path) async {}
}
