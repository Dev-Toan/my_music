import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers.dart';
import '../../widgets/track_tile.dart';
import 'folder_listing.dart';
import 'scan_feedback.dart';

/// Contents of one directory inside a library folder: subfolders first,
/// then the tracks that sit directly in it.
class FolderScreen extends ConsumerWidget {
  const FolderScreen({super.key, required this.folderId, this.dir = ''});

  final int folderId;

  /// Relative directory inside the folder, '' for its root.
  final String dir;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folder = ref.watch(folderProvider(folderId));
    final tracks = ref.watch(folderTracksProvider(folderId));
    final title = dir.isEmpty
        ? (folder?.displayName ?? '')
        : dir.split('/').last;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          if (folder?.isYoutube ?? false)
            IconButton(
              tooltip: 'Thêm từ link YouTube',
              icon: const Icon(Icons.add_link),
              onPressed: () => context.push('/youtube'),
            ),
        ],
      ),
      body: tracks.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Lỗi: $e')),
        data: (all) {
          final listing = listDirectory(all, dir);
          final empty = listing.subfolders.isEmpty && listing.tracks.isEmpty;
          return RefreshIndicator(
            onRefresh: () => runScan(context, ref),
            child: empty
                ? ListView(
                    children: const [
                      SizedBox(height: 120),
                      Center(child: Text('Không có bài hát nào')),
                    ],
                  )
                : ListView.builder(
                    itemCount:
                        listing.subfolders.length + listing.tracks.length,
                    itemBuilder: (context, i) {
                      if (i < listing.subfolders.length) {
                        final sub = listing.subfolders[i];
                        return ListTile(
                          leading: const Icon(Icons.folder_rounded, size: 32),
                          title: Text(sub.name),
                          subtitle: Text('${sub.trackCount} bài'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push(
                            Uri(
                              path: '/folder/$folderId',
                              queryParameters: {'dir': sub.relativeDir},
                            ).toString(),
                          ),
                        );
                      }
                      final t = listing.tracks[i - listing.subfolders.length];
                      return TrackTile(track: t, siblings: listing.tracks);
                    },
                  ),
          );
        },
      ),
    );
  }
}
