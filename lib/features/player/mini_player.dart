import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers.dart';
import '../../widgets/cover_art.dart';

/// Bar pinned to the bottom of every library screen. Shows the last played
/// track (paused after relaunch); tap to open the full player.
class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final item = ref.watch(mediaItemProvider).value;
    if (item == null) return const SizedBox.shrink();
    final playing = ref.watch(playbackStateProvider).value?.playing ?? false;
    final position = ref.watch(positionProvider).value ?? Duration.zero;
    final duration = item.duration;
    final handler = ref.read(audioHandlerProvider);
    final scheme = Theme.of(context).colorScheme;
    final progress = (duration == null || duration.inMilliseconds == 0)
        ? 0.0
        : (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);

    return Material(
      color: scheme.surfaceContainer,
      child: InkWell(
        onTap: () => context.push('/player'),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LinearProgressIndicator(value: progress, minHeight: 2),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
                child: Row(
                  children: [
                    Hero(
                      tag: 'cover',
                      child: CoverArt.fromUri(item.artUri, size: 44),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          if (item.artist != null)
                            Text(
                              item.artist!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      iconSize: 34,
                      icon: Icon(
                        playing
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                      ),
                      onPressed: playing ? handler.pause : handler.play,
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next_rounded),
                      onPressed: handler.skipToNext,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
