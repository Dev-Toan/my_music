import 'dart:io';

import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_music/core/app_paths.dart';
import 'package:my_music/core/db/database.dart';
import 'package:my_music/core/folder_access/folder_access.dart';
import 'package:my_music/features/library/folder_listing.dart';
import 'package:my_music/features/library/library_repository.dart';
import 'package:path/path.dart' as p;

/// Resolves bookmarks as plain paths, like Android/desktop.
class FakeAccess implements FolderAccess {
  final downloads = <String>[];
  @override
  Future<PickedFolder?> pickFolder() async => null;
  @override
  Future<ResolvedFolder> resolve(String bookmark) async =>
      ResolvedFolder(path: bookmark);
  @override
  Future<void> release(String path) async {}
  @override
  Future<void> requestDownload(String path) async => downloads.add(path);
}

void main() {
  late Directory tmp;
  late Directory music;
  late AppDatabase db;
  late FakeAccess access;
  late LibraryRepository repo;
  final removed = <int>[];

  void touch(String rel) {
    final f = File(p.joinAll([music.path, ...rel.split('/')]));
    f.parent.createSync(recursive: true);
    f.writeAsBytesSync(List.filled(64, 0));
  }

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('my_music_test');
    music = Directory(p.join(tmp.path, 'Music'))..createSync();
    db = AppDatabase(DatabaseConnection(NativeDatabase.memory()));
    access = FakeAccess();
    final paths = AppPaths(
      supportDir: p.join(tmp.path, 'support'),
      documentsDir: p.join(tmp.path, 'docs'),
    );
    Directory(paths.youtubeDir).createSync(recursive: true);
    removed.clear();
    repo = LibraryRepository(
      db: db,
      access: access,
      paths: paths,
      onTracksRemoved: (ids) async => removed.addAll(ids),
    );
  });

  tearDown(() async {
    await db.close();
    await tmp.delete(recursive: true);
  });

  test('scan adds, keeps and removes tracks', () async {
    touch('Sơn Tùng - Lạc Trôi.mp3');
    touch('Ballad/Bài buồn.m4a');
    touch('cover.jpg');
    touch('.hidden.mp3');
    touch('.Chưa tải.mp3.icloud');

    final id = await db.addFolder(music.path, 'Music', music.path);
    final folder = (await db.folderById(id))!;
    var r = await repo.scanFolder(folder);
    expect(r.added, 2);
    expect(r.icloudPending, 1);
    expect(access.downloads, hasLength(1));

    final tracks = await db.tracksInFolder(id);
    final lac = tracks.firstWhere((t) => t.fileName.startsWith('Sơn'));
    expect(lac.title, 'Lạc Trôi');
    expect(lac.artist, 'Sơn Tùng');
    expect(
      tracks.map((t) => t.relativePath),
      containsAll(['Sơn Tùng - Lạc Trôi.mp3', 'Ballad/Bài buồn.m4a']),
    );

    // Rescan with no changes keeps rows (and edited metadata).
    r = await repo.scanFolder(folder);
    expect(r.added, 0);
    expect(r.removed, 0);

    File(p.join(music.path, 'Sơn Tùng - Lạc Trôi.mp3')).deleteSync();
    touch('Mới.mp3');
    r = await repo.scanFolder(folder);
    expect(r.added, 1);
    expect(r.removed, 1);
    expect(removed, [lac.id]);
  });

  test('search matches without accents', () async {
    touch('Nhạc Buồn.mp3');
    touch('Vui.mp3');
    final id = await db.addFolder(music.path, 'Music', music.path);
    await repo.scanFolder((await db.folderById(id))!);
    final hits = await db.watchSearch('nhac buon').first;
    expect(hits.map((t) => t.title), ['Nhạc Buồn']);
  });

  test('listDirectory shows direct tracks and subfolders', () async {
    touch('a.mp3');
    touch('Rock/b.mp3');
    touch('Rock/Old/c.mp3');
    final id = await db.addFolder(music.path, 'Music', music.path);
    await repo.scanFolder((await db.folderById(id))!);
    final all = await db.tracksInFolder(id);

    final root = listDirectory(all, '');
    expect(root.tracks.map((t) => t.fileName), ['a.mp3']);
    expect(root.subfolders.single.name, 'Rock');
    expect(root.subfolders.single.trackCount, 2);

    final rock = listDirectory(all, 'Rock');
    expect(rock.tracks.map((t) => t.fileName), ['b.mp3']);
    expect(rock.subfolders.single.relativeDir, 'Rock/Old');
  });

  test('entries resolve to absolute paths and restore drops deleted', () async {
    touch('x.mp3');
    touch('y.mp3');
    final id = await db.addFolder(music.path, 'Music', music.path);
    final folder = (await db.folderById(id))!;
    await repo.scanFolder(folder);
    final tracks = await db.tracksInFolder(id);
    final entries = await repo.entriesFor(tracks);
    expect(entries.every((e) => File(e.filePath!).existsSync()), isTrue);

    await db.deleteTrack(tracks.first.id);
    final restored = await repo.refreshEntries(
      entries.map((e) => e.copyWith()).toList(),
    );
    expect(restored, hasLength(1));
  });
}
