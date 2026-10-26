import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../../providers.dart';
import '../../widgets/playback_actions.dart';
import '../library/scan_feedback.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _remove(BuildContext context, WidgetRef ref, Folder f) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Bỏ "${f.displayName}" khỏi thư viện?'),
        content: const Text('File nhạc trên máy vẫn được giữ nguyên.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Bỏ'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(libraryProvider).removeFolder(f);
    if (context.mounted) showMessage(context, 'Đã bỏ ${f.displayName}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folders = (ref.watch(foldersProvider).value ?? const <Folder>[])
        .where((f) => !f.isYoutube)
        .toList();
    final scanning = ref.watch(scanProvider).scanning;
    final library = ref.read(libraryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        children: [
          const ListTile(title: Text('Thư mục nhạc')),
          for (final f in folders)
            ListTile(
              leading: const Icon(Icons.folder_rounded),
              title: Text(f.displayName),
              subtitle: Text(
                library.isAvailable(f.id)
                    ? f.pathHint
                    : 'Mất quyền truy cập, hãy bỏ và chọn lại',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                tooltip: 'Bỏ khỏi thư viện',
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () => _remove(context, ref, f),
              ),
            ),
          ListTile(
            leading: const Icon(Icons.create_new_folder_outlined),
            title: const Text('Thêm thư mục'),
            onTap: () => addFolder(context, ref),
          ),
          ListTile(
            leading: scanning
                ? const SizedBox.square(
                    dimension: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            title: const Text('Quét lại toàn bộ'),
            onTap: scanning ? null : () => runScan(context, ref),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('YouTube không phát được?'),
            subtitle: Text(
              'YouTube hay đổi cơ chế. Cập nhật thư viện trích luồng rồi cài lại app:\n'
              'flutter pub upgrade youtube_explode_dart',
            ),
          ),
          const ListTile(
            leading: Icon(Icons.music_note_outlined),
            title: Text('My Music'),
            subtitle: Text('Phiên bản 1.0.0'),
          ),
        ],
      ),
    );
  }
}
