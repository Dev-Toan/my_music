import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/db/database.dart';
import '../providers.dart';

void showMessage(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}

/// Queue = exactly the list the user is looking at, starting at [tapped].
Future<void> playTrackList(
  BuildContext context,
  WidgetRef ref,
  List<Track> tracks,
  Track tapped,
) async {
  final entries = await ref.read(libraryProvider).entriesFor(tracks);
  final index = entries.indexWhere((e) => e.trackId == tapped.id);
  if (index < 0) {
    if (context.mounted) {
      showMessage(context, 'Không mở được thư mục chứa bài này');
    }
    return;
  }
  await ref.read(audioHandlerProvider).playEntries(entries, index);
}

Future<void> playTrackNext(BuildContext context, WidgetRef ref, Track t) async {
  final entry = await ref.read(libraryProvider).entryFor(t);
  if (entry == null) {
    if (context.mounted) {
      showMessage(context, 'Không mở được thư mục chứa bài này');
    }
    return;
  }
  await ref.read(audioHandlerProvider).playNext(entry);
  if (context.mounted) showMessage(context, 'Sẽ phát tiếp: ${t.title}');
}

Future<void> confirmDeleteTrack(
  BuildContext context,
  WidgetRef ref,
  Track t,
) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Xóa file?'),
      content: Text(
        '"${t.fileName}" sẽ bị xóa khỏi iPhone. Không thể hoàn tác.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Hủy'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(ctx).colorScheme.error,
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Xóa'),
        ),
      ],
    ),
  );
  if (ok != true) return;
  try {
    await ref.read(libraryProvider).deleteTrackFile(t);
    if (context.mounted) showMessage(context, 'Đã xóa ${t.fileName}');
  } catch (e) {
    if (context.mounted) showMessage(context, 'Không xóa được: $e');
  }
}
