# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

`my_music` is a personal offline music player for one user's iPhone, written in Flutter. It plays mp3/m4a files from folders the user picks in the iOS Files app, and can stream or download audio from a pasted YouTube link. It is installed via Xcode only, never published. The full spec and phased plan live in `docs/superpowers/specs/2026-10-23-my-music-design.md`.

Development happens on Windows without Visual Studio, so day-to-day testing runs on the **Android emulator**. iOS-only parts (folder bookmarks, lock screen) are only verifiable on a borrowed Mac; see section 7, phase 6 of the spec for the Mac-day checklist.

Toolchain: Flutter 3.47.7 stable, Dart `^3.13.5`. Code uses dot-shorthand and null-aware elements (`?x` in list literals); both are valid on this SDK.

## Commands

```sh
flutter pub get
dart run build_runner build          # regenerate lib/core/db/database.g.dart after editing tables
flutter run -d emulator-5554         # Android emulator (main dev target)
flutter analyze
flutter test                         # unit + in-memory drift tests
flutter test test/library_test.dart  # single file
flutter test --plain-name "search matches without accents"
flutter build apk --debug
```

Windows build quirks already handled in `android/`: `kotlin.incremental=false` (project on D:, pub cache on C:) and `compileSdk = 37` (required by permission_handler).

## Architecture

- `lib/main.dart` builds the singletons (AppPaths, AppDatabase, LibraryRepository, YoutubeService, MyAudioHandler via `AudioService.init`), reopens folder access, restores the last session paused, then injects everything through Riverpod overrides declared in `lib/providers.dart`.
- `core/audio/audio_handler.dart` is the **only** code that touches just_audio. The UI calls the handler; OS controls reach it through audio_service. Queue items are `QueueEntry` snapshots (`core/audio/queue_entry.dart`), persisted as JSON in the single-row `player_states` table. File paths and YouTube stream URLs are transient and re-resolved on restore/play.
- Deliberate behaviours: never auto-play on headset connect or after an interruption ends (`handleInterruptions: false`, custom audio_session handling); pause on unplug. Lock screen shows prev/play/next only; ±5s is in-app.
- `core/folder_access/` abstracts folder picking: plain paths on Android/desktop, a MethodChannel `my_music/folder` on iOS implemented by `FolderPickerPlugin` inside `ios/Runner/AppDelegate.swift` (security-scoped bookmarks, iCloud placeholder download).
- `features/library/library_repository.dart` scans folders recursively, keys tracks by `(folder_id, relative_path)`, and maps tracks to `QueueEntry`. The DB stores paths relative to the folder root and covers relative to the app support dir, because the iOS container path changes between installs.
- The YouTube folder is a special `folders` row (`is_youtube`) whose root is `Documents/YouTube`; downloads land there as `.m4a` (no mp3 conversion).
- Folder tree views are derived in memory from the flat track list (`features/library/folder_listing.dart`). Tapping a track queues exactly the list on screen.
- Search uses the `search_text` column (lower-case, diacritics stripped via `core/utils/normalize_vi.dart`).
