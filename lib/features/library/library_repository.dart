import 'dart:io';
import 'dart:isolate';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../../core/app_paths.dart';
import '../../core/audio/queue_entry.dart';
import '../../core/db/database.dart';
import '../../core/folder_access/folder_access.dart';
import '../../core/utils/filename_parser.dart';
import '../../core/utils/normalize_vi.dart';

class ScanResult {
  const ScanResult({
    this.added = 0,
    this.removed = 0,
    this.icloudPending = 0,
    this.failedFolders = const [],
  });

  final int added;
  final int removed;

  /// iCloud placeholders we asked iOS to download; they show up next scan.
  final int icloudPending;
  final List<String> failedFolders;

  ScanResult operator +(ScanResult o) => ScanResult(
    added: added + o.added,
    removed: removed + o.removed,
    icloudPending: icloudPending + o.icloudPending,
    failedFolders: [...failedFolders, ...o.failedFolders],
  );
}

/// Owns folder access, scanning, and mapping tracks to playable entries.
class LibraryRepository {
  LibraryRepository({
    required this.db,
    required this.access,
    required this.paths,
    this.onTracksRemoved,
  });

  final AppDatabase db;
  final FolderAccess access;
  final AppPaths paths;
  Future<void> Function(List<int> trackIds)? onTracksRemoved;

  /// folderId -> absolute root path, filled by [openFolder].
  final Map<int, String> _roots = {};

  bool isAvailable(int folderId) => _roots.containsKey(folderId);

  Future<String?> rootOf(Folder f) async =>
      _roots[f.id] ?? (await openFolder(f) ? _roots[f.id] : null);

  String? absolutePath(Track t) {
    final root = _roots[t.folderId];
    if (root == null) return null;
    return p.joinAll([root, ...t.relativePath.split('/')]);
  }

  /// Regains access to a folder (iOS bookmark resolution). Returns false if
  /// the folder is gone or access was revoked.
  Future<bool> openFolder(Folder f) async {
    if (f.isYoutube) {
      _roots[f.id] = paths.youtubeDir;
      return true;
    }
    try {
      final resolved = await access.resolve(f.bookmark);
      _roots[f.id] = resolved.path;
      if (resolved.refreshedBookmark != null) {
        await db.updateBookmark(f.id, resolved.refreshedBookmark!);
      }
      return true;
    } catch (e) {
      debugPrint('openFolder ${f.displayName} failed: $e');
      _roots.remove(f.id);
      return false;
    }
  }

  /// Opens the system picker and adds the folder. Returns null if cancelled,
  /// or the existing folder id if it was already in the library.
  Future<int?> pickAndAddFolder() async {
    final picked = await access.pickFolder();
    if (picked == null) return null;
    for (final f in await db.allFolders()) {
      if (!f.isYoutube && await rootOf(f) == picked.path) return f.id;
    }
    final id = await db.addFolder(picked.bookmark, picked.name, picked.path);
    _roots[id] = picked.path;
    await scanFolder((await db.folderById(id))!);
    return id;
  }

  Future<void> removeFolder(Folder f) async {
    final ids = (await db.tracksInFolder(f.id)).map((t) => t.id).toList();
    await onTracksRemoved?.call(ids);
    final root = _roots.remove(f.id);
    if (root != null) await access.release(root);
    await db.removeFolder(f.id);
  }

  Future<ScanResult> scanAll() async {
    await db.youtubeFolder();
    var total = const ScanResult();
    for (final f in await db.allFolders()) {
      total += await scanFolder(f);
    }
    return total;
  }

  Future<ScanResult> scanFolder(Folder f) async {
    final root = await rootOf(f);
    if (root == null || !await Directory(root).exists()) {
      return ScanResult(failedFolders: [f.displayName]);
    }

    final existing = {
      for (final t in await db.tracksInFolder(f.id)) t.relativePath: t,
    };
    final seen = <String>{};
    final newFiles = <String, String>{}; // relativePath -> absolute
    var icloud = 0;

    try {
      final dir = Directory(root);
      await for (final entity in dir.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is! File) continue;
        final name = p.basename(entity.path);
        // iCloud Drive placeholder looks like ".Song.mp3.icloud"
        if (name.startsWith('.') && name.endsWith('.icloud')) {
          final real = name.substring(1, name.length - 7);
          if (supportedExtensions.contains(p.extension(real).toLowerCase())) {
            icloud++;
            await access.requestDownload(entity.path);
          }
          continue;
        }
        if (name.startsWith('.')) continue;
        if (!supportedExtensions.contains(p.extension(name).toLowerCase())) {
          continue;
        }
        final rel = p.split(p.relative(entity.path, from: root)).join('/');
        seen.add(rel);
        if (!existing.containsKey(rel)) newFiles[rel] = entity.path;
      }
    } on FileSystemException catch (e) {
      debugPrint('scan ${f.displayName} failed: $e');
      return ScanResult(failedFolders: [f.displayName]);
    }

    final now = DateTime.now();
    final durations = await _readDurations(newFiles.values.toList());
    await db.batch((b) {
      for (final entry in newFiles.entries) {
        final fileName = p.posix.basename(entry.key);
        final parsed = parseFileName(fileName);
        b.insert(
          db.tracks,
          TracksCompanion.insert(
            folderId: f.id,
            relativePath: entry.key,
            fileName: fileName,
            title: parsed.title,
            artist: Value(parsed.artist),
            durationMs: Value(durations[entry.value]),
            searchText: buildSearchText(
              title: parsed.title,
              artist: parsed.artist,
              fileName: fileName,
            ),
            source: TrackSource.local,
            lastSeenAt: now,
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
    });

    final removed = [
      for (final e in existing.entries)
        if (!seen.contains(e.key)) e.value.id,
    ];
    if (removed.isNotEmpty) {
      await onTracksRemoved?.call(removed);
      await db.deleteTracks(removed);
    }
    return ScanResult(
      added: newFiles.length,
      removed: removed.length,
      icloudPending: icloud,
    );
  }

  /// Reads durations off the UI isolate. Files we cannot parse get null.
  static Future<Map<String, int?>> _readDurations(List<String> files) async {
    if (files.isEmpty) return {};
    return Isolate.run(() {
      final out = <String, int?>{};
      for (final path in files) {
        try {
          out[path] = readMetadata(File(path)).duration?.inMilliseconds;
        } catch (_) {
          out[path] = null;
        }
      }
      return out;
    });
  }

  // ---------------- playback mapping ----------------

  Future<QueueEntry?> entryFor(Track t, {Folder? folder}) async {
    final f = folder ?? await db.folderById(t.folderId);
    if (f == null) return null;
    if (absolutePath(t) == null && !await openFolder(f)) return null;
    return QueueEntry(
      trackId: t.id,
      youtubeId: t.youtubeId,
      title: t.title,
      artist: t.artist,
      album: f.displayName,
      coverFile: paths.absoluteCover(t.coverPath),
      durationMs: t.durationMs,
      filePath: absolutePath(t),
    );
  }

  Future<List<QueueEntry>> entriesFor(List<Track> tracks) async {
    final folders = {for (final f in await db.allFolders()) f.id: f};
    final out = <QueueEntry>[];
    for (final t in tracks) {
      final e = await entryFor(t, folder: folders[t.folderId]);
      if (e != null) out.add(e);
    }
    return out;
  }

  /// Used when restoring the saved queue: refreshes local tracks from the DB
  /// and drops the ones that no longer exist. Streams are kept as-is.
  Future<List<QueueEntry>> refreshEntries(List<QueueEntry> saved) async {
    final ids = saved.map((e) => e.trackId).whereType<int>().toList();
    final tracks = {for (final t in await db.tracksByIds(ids)) t.id: t};
    final folders = {for (final f in await db.allFolders()) f.id: f};
    final out = <QueueEntry>[];
    for (final e in saved) {
      if (e.isStream) {
        out.add(e);
        continue;
      }
      final t = tracks[e.trackId];
      if (t == null) continue;
      final fresh = await entryFor(t, folder: folders[t.folderId]);
      if (fresh != null) out.add(fresh);
    }
    return out;
  }

  // ---------------- edits ----------------

  Future<void> updateMetadata(
    Track t, {
    required String title,
    String? artist,
    String? newCoverSource,
  }) async {
    var coverRel = t.coverPath;
    if (newCoverSource != null) {
      final ext = p.extension(newCoverSource).isEmpty
          ? '.jpg'
          : p.extension(newCoverSource);
      final stamp = DateTime.now().millisecondsSinceEpoch;
      coverRel = 'covers/${t.id}_$stamp$ext';
      await File(newCoverSource).copy(p.join(paths.supportDir, coverRel));
      await _deleteCover(t.coverPath);
    }
    final cleanTitle = title.trim().isEmpty
        ? stripExtension(t.fileName)
        : title.trim();
    final a = artist?.trim();
    final cleanArtist = (a == null || a.isEmpty) ? null : a;
    await db.updateTrack(
      t.id,
      TracksCompanion(
        title: Value(cleanTitle),
        artist: Value(cleanArtist),
        coverPath: Value(coverRel),
        searchText: Value(
          buildSearchText(
            title: cleanTitle,
            artist: cleanArtist,
            fileName: t.fileName,
          ),
        ),
      ),
    );
  }

  /// Deletes the audio file from disk and from the library.
  Future<void> deleteTrackFile(Track t) async {
    await onTracksRemoved?.call([t.id]);
    final path = absolutePath(t);
    if (path != null) {
      final file = File(path);
      if (await file.exists()) await file.delete();
    }
    await _deleteCover(t.coverPath);
    if (t.youtubeId != null) await db.markDownloaded(t.youtubeId!, null);
    await db.deleteTrack(t.id);
  }

  Future<void> _deleteCover(String? rel) async {
    if (rel == null) return;
    final file = File(p.join(paths.supportDir, rel));
    if (await file.exists()) await file.delete();
  }
}
