import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/database.dart';
import '../../providers.dart';
import 'scan_feedback.dart';

/// Root screen: the folder tree. First launch shows the folder picker.
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  @override
  void initState() {
    super.initState();
    // Re-scan every launch so new / deleted files are picked up.
    WidgetsBinding.instance.addPostFrameCallback((_) => runScan(context, ref));
  }

  @override
  Widget build(BuildContext context) {
    final folders = ref.watch(foldersProvider);
    final scanning = ref.watch(scanProvider).scanning;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thư viện'),
        actions: [
          IconButton(
            tooltip: 'Cài đặt',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Material(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(28),
              child: InkWell(
                borderRadius: BorderRadius.circular(28),
                onTap: () => context.push('/search'),
                child: const SizedBox(
                  height: 48,
                  child: Row(
                    children: [
                      SizedBox(width: 16),
                      Icon(Icons.search),
                      SizedBox(width: 12),
                      Text('Tìm bài hát'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: folders.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
        data: (list) {
          final user = list.where((f) => !f.isYoutube).toList();
          final youtube = list.where((f) => f.isYoutube).firstOrNull;
          if (user.isEmpty) return _Onboarding(youtube: youtube);
          return RefreshIndicator(
            onRefresh: () => runScan(context, ref),
            child: ListView(
              children: [
                if (scanning) const LinearProgressIndicator(minHeight: 2),
                for (final f in user) _FolderTile(folder: f),
                if (youtube != null) _FolderTile(folder: youtube),
                ListTile(
                  leading: const Icon(Icons.add_link),
                  title: const Text('Nghe từ link YouTube'),
                  onTap: () => context.push('/youtube'),
                ),
                ListTile(
                  leading: const Icon(Icons.create_new_folder_outlined),
                  title: const Text('Thêm thư mục'),
                  onTap: () => addFolder(context, ref),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FolderTile extends ConsumerWidget {
  const _FolderTile({required this.folder});
  final Folder folder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(folderTracksProvider(folder.id)).value?.length;
    final available =
        folder.isYoutube || ref.read(libraryProvider).isAvailable(folder.id);
    return ListTile(
      leading: Icon(
        folder.isYoutube ? Icons.smart_display_outlined : Icons.folder_rounded,
        size: 32,
      ),
      title: Text(folder.displayName),
      subtitle: Text(
        available
            ? '${count ?? 0} bài'
            : 'Không truy cập được, chọn lại thư mục',
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push('/folder/${folder.id}'),
    );
  }
}

class _Onboarding extends ConsumerWidget {
  const _Onboarding({this.youtube});
  final Folder? youtube;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.library_music_rounded, size: 96),
            const SizedBox(height: 16),
            const Text(
              'Chọn thư mục chứa nhạc của bạn. Lần sau app sẽ tự quét lại.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.folder_open),
              label: const Text('Chọn thư mục nhạc'),
              onPressed: () => addFolder(context, ref),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              icon: const Icon(Icons.add_link),
              label: const Text('Hoặc nghe từ link YouTube'),
              onPressed: () => context.push('/youtube'),
            ),
          ],
        ),
      ),
    );
  }
}
