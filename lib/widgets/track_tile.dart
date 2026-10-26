import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/db/database.dart';
import '../core/utils/filename_parser.dart';
import '../providers.dart';
import 'cover_art.dart';
import 'playback_actions.dart';

enum _TrackAction { playNext, edit, delete }

/// A row in a track list. Tap plays [siblings] starting here; the menu
/// offers play-next, edit info and delete.
class TrackTile extends ConsumerWidget {
  const TrackTile({
    super.key,
    required this.track,
    required this.siblings,
    this.subtitlePrefix,
  });

  final Track track;
  final List<Track> siblings;

  /// e.g. the folder name in search results.
  final String? subtitlePrefix;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(mediaItemProvider).value;
    final isCurrent = current?.id == 't:${track.id}';
    final paths = ref.watch(pathsProvider);
    final scheme = Theme.of(context).colorScheme;
    final subtitleParts = [?subtitlePrefix, ?track.artist];

    return ListTile(
      leading: CoverArt(file: paths.absoluteCover(track.coverPath)),
      title: Text(
        track.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: isCurrent ? TextStyle(color: scheme.primary) : null,
      ),
      subtitle: subtitleParts.isEmpty
          ? null
          : Text(
              subtitleParts.join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formatDuration(
              track.durationMs == null
                  ? null
                  : Duration(milliseconds: track.durationMs!),
            ),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          PopupMenuButton<_TrackAction>(
            icon: const Icon(Icons.more_vert),
            onSelected: (a) => _onAction(context, ref, a),
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: _TrackAction.playNext,
                child: ListTile(
                  leading: Icon(Icons.queue_play_next),
                  title: Text('Phát tiếp theo'),
                ),
              ),
              PopupMenuItem(
                value: _TrackAction.edit,
                child: ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Sửa thông tin'),
                ),
              ),
              PopupMenuItem(
                value: _TrackAction.delete,
                child: ListTile(
                  leading: Icon(Icons.delete_outline),
                  title: Text('Xóa file'),
                ),
              ),
            ],
          ),
        ],
      ),
      onTap: () => playTrackList(context, ref, siblings, track),
      onLongPress: () => playTrackNext(context, ref, track),
    );
  }

  void _onAction(BuildContext context, WidgetRef ref, _TrackAction a) {
    switch (a) {
      case _TrackAction.playNext:
        playTrackNext(context, ref, track);
      case _TrackAction.edit:
        context.push('/edit/${track.id}');
      case _TrackAction.delete:
        confirmDeleteTrack(context, ref, track);
    }
  }
}
