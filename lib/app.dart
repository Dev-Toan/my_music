import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/library/folder_screen.dart';
import 'features/library/library_screen.dart';
import 'features/metadata/edit_track_screen.dart';
import 'features/player/mini_player.dart';
import 'features/player/player_screen.dart';
import 'features/player/queue_screen.dart';
import 'features/search/search_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/youtube/youtube_screen.dart';
import 'providers.dart';

final _rootKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootKey,
  routes: [
    ShellRoute(
      builder: (context, state, child) => _Shell(child: child),
      routes: [
        GoRoute(path: '/', builder: (_, _) => const LibraryScreen()),
        GoRoute(
          path: '/folder/:id',
          builder: (_, s) => FolderScreen(
            folderId: int.parse(s.pathParameters['id']!),
            dir: s.uri.queryParameters['dir'] ?? '',
          ),
        ),
        GoRoute(path: '/search', builder: (_, _) => const SearchScreen()),
        GoRoute(path: '/youtube', builder: (_, _) => const YoutubeScreen()),
        GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
        GoRoute(
          path: '/edit/:id',
          builder: (_, s) =>
              EditTrackScreen(trackId: int.parse(s.pathParameters['id']!)),
        ),
      ],
    ),
    // Full-screen pages without the mini player.
    GoRoute(
      path: '/player',
      parentNavigatorKey: _rootKey,
      pageBuilder: (_, s) => CustomTransitionPage(
        key: s.pageKey,
        child: const PlayerScreen(),
        transitionsBuilder: (_, animation, _, child) => SlideTransition(
          position: Tween(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(animation),
          child: child,
        ),
      ),
    ),
    GoRoute(
      path: '/queue',
      parentNavigatorKey: _rootKey,
      builder: (_, _) => const QueueScreen(),
    ),
  ],
);

final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// Wraps library screens and pins the mini player to the bottom.
class _Shell extends StatelessWidget {
  const _Shell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: child, bottomNavigationBar: const MiniPlayer());
}

class MyMusicApp extends ConsumerStatefulWidget {
  const MyMusicApp({super.key});

  @override
  ConsumerState<MyMusicApp> createState() => _MyMusicAppState();
}

class _MyMusicAppState extends ConsumerState<MyMusicApp> {
  @override
  void initState() {
    super.initState();
    // Player errors (missing file, expired YouTube link, no network...).
    ref.read(audioHandlerProvider).errors.listen((msg) {
      scaffoldMessengerKey.currentState
        ?..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(msg)));
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1DB98A),
      brightness: Brightness.dark,
    ).copyWith(surface: const Color(0xFF101413));

    return MaterialApp.router(
      title: 'My Music',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: scaffoldMessengerKey,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        colorScheme: scheme,
        scaffoldBackgroundColor: scheme.surface,
        appBarTheme: AppBarTheme(backgroundColor: scheme.surface),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
      ),
      theme: ThemeData(colorScheme: scheme),
      routerConfig: router,
    );
  }
}
