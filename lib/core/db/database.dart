import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

/// A music folder the user picked (or the app-managed YouTube folder).
class Folders extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// iOS: base64 security-scoped bookmark. Other platforms: absolute path.
  /// Empty for the YouTube folder, whose path is resolved at runtime.
  TextColumn get bookmark => text()();
  TextColumn get displayName => text()();
  TextColumn get pathHint => text().withDefault(const Constant(''))();
  BoolColumn get isYoutube => boolean().withDefault(const Constant(false))();
  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();
}

enum TrackSource { local, youtube }

class Tracks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get folderId =>
      integer().references(Folders, #id, onDelete: KeyAction.cascade)();

  /// Path relative to the folder root, always with `/` separators.
  TextColumn get relativePath => text()();
  TextColumn get fileName => text()();
  TextColumn get title => text()();
  TextColumn get artist => text().nullable()();
  IntColumn get durationMs => integer().nullable()();

  /// Cover image path relative to the app support directory.
  TextColumn get coverPath => text().nullable()();

  /// Lower-case, diacritic-free text used by search.
  TextColumn get searchText => text()();
  IntColumn get source => intEnum<TrackSource>()();
  TextColumn get youtubeId => text().nullable()();
  DateTimeColumn get lastSeenAt => dateTime()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {folderId, relativePath},
  ];
}

class YoutubeHistory extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get videoId => text().unique()();
  TextColumn get title => text()();
  TextColumn get author => text().withDefault(const Constant(''))();
  TextColumn get thumbnailUrl => text()();
  IntColumn get durationMs => integer().nullable()();
  IntColumn get downloadedTrackId => integer().nullable()();
  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Single-row table holding the serialized player state.
class PlayerStates extends Table {
  IntColumn get id => integer()();
  TextColumn get json => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Folders, Tracks, YoutubeHistory, PlayerStates])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _open());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  static QueryExecutor _open() => driftDatabase(
    name: 'my_music',
    // Not the Documents dir: on iOS that one is visible in the Files app.
    native: const DriftNativeOptions(
      databaseDirectory: getApplicationSupportDirectory,
    ),
  );

  // ---------- folders ----------

  Stream<List<Folder>> watchFolders() =>
      (select(folders)..orderBy([
            (f) => OrderingTerm.asc(f.isYoutube),
            (f) => OrderingTerm.asc(f.addedAt),
          ]))
          .watch();

  Future<List<Folder>> allFolders() => select(folders).get();

  Future<Folder?> folderById(int id) =>
      (select(folders)..where((f) => f.id.equals(id))).getSingleOrNull();

  Future<Folder> youtubeFolder() async {
    final existing = await (select(
      folders,
    )..where((f) => f.isYoutube.equals(true))).getSingleOrNull();
    if (existing != null) return existing;
    final id = await into(folders).insert(
      FoldersCompanion.insert(
        bookmark: '',
        displayName: 'YouTube',
        isYoutube: const Value(true),
      ),
    );
    return (await folderById(id))!;
  }

  Future<int> addFolder(String bookmark, String name, String pathHint) =>
      into(folders).insert(
        FoldersCompanion.insert(
          bookmark: bookmark,
          displayName: name,
          pathHint: Value(pathHint),
        ),
      );

  Future<void> updateBookmark(int id, String bookmark) =>
      (update(folders)..where((f) => f.id.equals(id))).write(
        FoldersCompanion(bookmark: Value(bookmark)),
      );

  Future<void> removeFolder(int id) =>
      (delete(folders)..where((f) => f.id.equals(id))).go();

  // ---------- tracks ----------

  Stream<List<Track>> watchTracksInFolder(int folderId) =>
      (select(tracks)..where((t) => t.folderId.equals(folderId))).watch();

  Future<List<Track>> tracksInFolder(int folderId) =>
      (select(tracks)..where((t) => t.folderId.equals(folderId))).get();

  Future<Track?> trackById(int id) =>
      (select(tracks)..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<Track?> watchTrack(int id) =>
      (select(tracks)..where((t) => t.id.equals(id))).watchSingleOrNull();

  Future<List<Track>> tracksByIds(Iterable<int> ids) =>
      (select(tracks)..where((t) => t.id.isIn(ids))).get();

  Stream<List<Track>> watchSearch(String normalizedQuery) {
    final q = '%${normalizedQuery.replaceAll('%', '').replaceAll('_', '')}%';
    return (select(tracks)
          ..where((t) => t.searchText.like(q))
          ..limit(300))
        .watch();
  }

  Future<int> insertTrack(TracksCompanion t) => into(tracks).insert(t);

  /// Inserts or replaces the track at (folderId, relativePath); returns id.
  Future<int> upsertTrackByPath(TracksCompanion t) async {
    await into(tracks).insert(
      t,
      onConflict: DoUpdate(
        (_) => t,
        target: [tracks.folderId, tracks.relativePath],
      ),
    );
    final row =
        await (select(tracks)..where(
              (x) =>
                  x.folderId.equals(t.folderId.value) &
                  x.relativePath.equals(t.relativePath.value),
            ))
            .getSingle();
    return row.id;
  }

  Future<void> updateTrack(int id, TracksCompanion t) =>
      (update(tracks)..where((x) => x.id.equals(id))).write(t);

  Future<void> deleteTrack(int id) =>
      (delete(tracks)..where((t) => t.id.equals(id))).go();

  Future<void> deleteTracks(Iterable<int> ids) =>
      (delete(tracks)..where((t) => t.id.isIn(ids))).go();

  // ---------- youtube history ----------

  Stream<List<YoutubeHistoryData>> watchYoutubeHistory() =>
      (select(youtubeHistory)
            ..orderBy([(h) => OrderingTerm.desc(h.addedAt)])
            ..limit(100))
          .watch();

  Future<void> upsertHistory(YoutubeHistoryCompanion h) =>
      into(youtubeHistory).insert(
        h,
        onConflict: DoUpdate(
          (old) => YoutubeHistoryCompanion(
            title: h.title,
            author: h.author,
            thumbnailUrl: h.thumbnailUrl,
            durationMs: h.durationMs,
            addedAt: Value(DateTime.now()),
          ),
          target: [youtubeHistory.videoId],
        ),
      );

  Future<void> markDownloaded(String videoId, int? trackId) =>
      (update(youtubeHistory)..where((h) => h.videoId.equals(videoId))).write(
        YoutubeHistoryCompanion(downloadedTrackId: Value(trackId)),
      );

  Future<void> deleteHistory(int id) =>
      (delete(youtubeHistory)..where((h) => h.id.equals(id))).go();

  // ---------- player state ----------

  Future<String?> loadPlayerState() async {
    final row = await (select(
      playerStates,
    )..where((p) => p.id.equals(1))).getSingleOrNull();
    return row?.json;
  }

  Future<void> savePlayerState(String json) => into(playerStates)
      .insertOnConflictUpdate(
        PlayerStatesCompanion.insert(id: const Value(1), json: json),
      );
}
