import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';
import '../../widgets/cover_art.dart';

/// Upcoming tracks. Drag to reorder, swipe left to remove, tap to jump.
class QueueScreen extends ConsumerWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.watch(queueProvider).value ?? const [];
    final current = ref.watch(playbackStateProvider).value?.queueIndex;
    final handler = ref.read(audioHandlerProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('Hàng đợi (${queue.length})')),
      body: queue.isEmpty
          ? const Center(child: Text('Hàng đợi trống'))
          : ReorderableListView.builder(
              itemCount: queue.length,
              onReorderItem: handler.moveQueueItem,
              itemBuilder: (context, i) {
                final item = queue[i];
                final isCurrent = i == current;
                return Dismissible(
                  key: ValueKey('${item.id}#$i'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: scheme.errorContainer,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    child: const Icon(Icons.delete_outline),
                  ),
                  onDismissed: (_) => handler.removeQueueItemAt(i),
                  child: ListTile(
                    leading: CoverArt.fromUri(item.artUri, size: 44),
                    title: Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: isCurrent
                          ? TextStyle(
                              color: scheme.primary,
                              fontWeight: FontWeight.bold,
                            )
                          : null,
                    ),
                    subtitle: item.artist == null
                        ? null
                        : Text(item.artist!, maxLines: 1),
                    trailing: isCurrent
                        ? Icon(Icons.graphic_eq_rounded, color: scheme.primary)
                        : const Icon(Icons.drag_handle),
                    onTap: () => handler.skipToQueueItem(i),
                  ),
                );
              },
            ),
    );
  }
}
