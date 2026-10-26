import 'package:audio_service/audio_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/app_paths.dart';
import 'core/audio/audio_handler.dart';
import 'core/db/database.dart';
import 'features/library/library_repository.dart';
import 'features/youtube/youtube_service.dart';

// Singletons created in main() and injected through overrides.
final databaseProvider = Provider<AppDatabase>(
  (_) => throw UnimplementedError(),
);
final pathsProvider = Provider<AppPaths>((_) => throw UnimplementedError());
final audioHandlerProvider = Provider<MyAudioHandler>(
  (_) => throw UnimplementedError(),
);
final libraryProvider = Provider<LibraryRepository>(
  (_) => throw UnimplementedError(),
);
final youtubeProvider = Provider<YoutubeService>(
  (_) => throw UnimplementedError(),
);

// ---------------- library data ----------------

final foldersProvider = StreamProvider<List<Folder>>(
  (ref) => ref.watch(databaseProvider).watchFolders(),
);

final folderProvider = Provider.family<Folder?, int>((ref, id) {
  final folders = ref.watch(foldersProvider).value ?? const [];
  for (final f in folders) {
    if (f.id == id) return f;
  }
  return null;
});

final folderTracksProvider = StreamProvider.family<List<Track>, int>(
  (ref, folderId) => ref.watch(databaseProvider).watchTracksInFolder(folderId),
);

final trackProvider = StreamProvider.family<Track?, int>(
  (ref, id) => ref.watch(databaseProvider).watchTrack(id),
);

final youtubeHistoryProvider = StreamProvider<List<YoutubeHistoryData>>(
  (ref) => ref.watch(databaseProvider).watchYoutubeHistory(),
);

// ---------------- scanning ----------------

class ScanState {
  const ScanState({this.scanning = false, this.last});
  final bool scanning;
  final ScanResult? last;
}

class ScanController extends Notifier<ScanState> {
  @override
  ScanState build() => const ScanState();

  Future<ScanResult?> scanAll() async {
    if (state.scanning) return null;
    state = ScanState(scanning: true, last: state.last);
    try {
      final r = await ref.read(libraryProvider).scanAll();
      state = ScanState(last: r);
      return r;
    } catch (_) {
      state = ScanState(last: state.last);
      rethrow;
    }
  }
}

final scanProvider = NotifierProvider<ScanController, ScanState>(
  ScanController.new,
);

// ---------------- player ----------------

final mediaItemProvider = StreamProvider<MediaItem?>(
  (ref) => ref.watch(audioHandlerProvider).mediaItem,
);

final playbackStateProvider = StreamProvider<PlaybackState>(
  (ref) => ref.watch(audioHandlerProvider).playbackState,
);

final queueProvider = StreamProvider<List<MediaItem>>(
  (ref) => ref.watch(audioHandlerProvider).queue,
);

/// Position for progress bars, polled from the handler so it also works
/// before the player is loaded (restored session) and without audio_service.
final positionProvider = StreamProvider<Duration>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return Stream.periodic(
    const Duration(milliseconds: 250),
    (_) => handler.position,
  ).distinct();
});

// ---------------- youtube downloads ----------------

/// videoId -> progress (0..1) for downloads in flight.
class DownloadsController extends Notifier<Map<String, double>> {
  final _cancelled = <String>{};

  @override
  Map<String, double> build() => const {};

  /// Returns the new track id, or null if cancelled.
  Future<int?> start(YoutubeVideoInfo info) async {
    if (state.containsKey(info.id)) return null;
    _cancelled.remove(info.id);
    state = {...state, info.id: 0};
    try {
      return await ref
          .read(youtubeProvider)
          .download(
            info,
            onProgress: (v) => state = {...state, info.id: v},
            isCancelled: () => _cancelled.contains(info.id),
          );
    } on DownloadCancelled {
      return null;
    } finally {
      state = Map.of(state)..remove(info.id);
    }
  }

  void cancel(String videoId) => _cancelled.add(videoId);
}

final downloadsProvider =
    NotifierProvider<DownloadsController, Map<String, double>>(
      DownloadsController.new,
    );
