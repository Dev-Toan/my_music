import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/app_paths.dart';
import 'core/audio/audio_handler.dart';
import 'core/db/database.dart';
import 'core/folder_access/folder_access.dart';
import 'features/library/library_repository.dart';
import 'features/youtube/youtube_service.dart';
import 'providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final paths = await AppPaths.init();
  final db = AppDatabase();
  final youtube = YoutubeService(db: db, paths: paths);
  final library = LibraryRepository(
    db: db,
    access: FolderAccess.forPlatform(),
    paths: paths,
  );

  MyAudioHandler build() => MyAudioHandler(
    streamSource: youtube.audioSource,
    persist: db.savePlayerState,
  );

  MyAudioHandler handler;
  try {
    handler = await AudioService.init(
      builder: build,
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'my_music.playback',
        androidNotificationChannelName: 'Phát nhạc',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
        fastForwardInterval: seekStep,
        rewindInterval: seekStep,
      ),
    );
  } catch (e) {
    // Platforms without audio_service support (desktop dev builds).
    debugPrint('AudioService.init failed, running without OS controls: $e');
    handler = build();
  }

  library.onTracksRemoved = (ids) async {
    for (final id in ids) {
      await handler.removeTrackEverywhere(id);
    }
  };

  // Regain folder access before restoring, so saved tracks resolve to paths.
  await db.youtubeFolder();
  for (final f in await db.allFolders()) {
    await library.openFolder(f);
  }
  final saved = await db.loadPlayerState();
  if (saved != null) await handler.restore(saved, library.refreshEntries);
  handler.enablePersistence();

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        pathsProvider.overrideWithValue(paths),
        audioHandlerProvider.overrideWithValue(handler),
        libraryProvider.overrideWithValue(library),
        youtubeProvider.overrideWithValue(youtube),
      ],
      child: const MyMusicApp(),
    ),
  );
}
