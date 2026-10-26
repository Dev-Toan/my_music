// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $FoldersTable extends Folders with TableInfo<$FoldersTable, Folder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoldersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bookmarkMeta = const VerificationMeta(
    'bookmark',
  );
  @override
  late final GeneratedColumn<String> bookmark = GeneratedColumn<String>(
    'bookmark',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pathHintMeta = const VerificationMeta(
    'pathHint',
  );
  @override
  late final GeneratedColumn<String> pathHint = GeneratedColumn<String>(
    'path_hint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isYoutubeMeta = const VerificationMeta(
    'isYoutube',
  );
  @override
  late final GeneratedColumn<bool> isYoutube = GeneratedColumn<bool>(
    'is_youtube',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_youtube" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookmark,
    displayName,
    pathHint,
    isYoutube,
    addedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'folders';
  @override
  VerificationContext validateIntegrity(
    Insertable<Folder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('bookmark')) {
      context.handle(
        _bookmarkMeta,
        bookmark.isAcceptableOrUnknown(data['bookmark']!, _bookmarkMeta),
      );
    } else if (isInserting) {
      context.missing(_bookmarkMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('path_hint')) {
      context.handle(
        _pathHintMeta,
        pathHint.isAcceptableOrUnknown(data['path_hint']!, _pathHintMeta),
      );
    }
    if (data.containsKey('is_youtube')) {
      context.handle(
        _isYoutubeMeta,
        isYoutube.isAcceptableOrUnknown(data['is_youtube']!, _isYoutubeMeta),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Folder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Folder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bookmark: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bookmark'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      pathHint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path_hint'],
      )!,
      isYoutube: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_youtube'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $FoldersTable createAlias(String alias) {
    return $FoldersTable(attachedDatabase, alias);
  }
}

class Folder extends DataClass implements Insertable<Folder> {
  final int id;

  /// iOS: base64 security-scoped bookmark. Other platforms: absolute path.
  /// Empty for the YouTube folder, whose path is resolved at runtime.
  final String bookmark;
  final String displayName;
  final String pathHint;
  final bool isYoutube;
  final DateTime addedAt;
  const Folder({
    required this.id,
    required this.bookmark,
    required this.displayName,
    required this.pathHint,
    required this.isYoutube,
    required this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['bookmark'] = Variable<String>(bookmark);
    map['display_name'] = Variable<String>(displayName);
    map['path_hint'] = Variable<String>(pathHint);
    map['is_youtube'] = Variable<bool>(isYoutube);
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  FoldersCompanion toCompanion(bool nullToAbsent) {
    return FoldersCompanion(
      id: Value(id),
      bookmark: Value(bookmark),
      displayName: Value(displayName),
      pathHint: Value(pathHint),
      isYoutube: Value(isYoutube),
      addedAt: Value(addedAt),
    );
  }

  factory Folder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Folder(
      id: serializer.fromJson<int>(json['id']),
      bookmark: serializer.fromJson<String>(json['bookmark']),
      displayName: serializer.fromJson<String>(json['displayName']),
      pathHint: serializer.fromJson<String>(json['pathHint']),
      isYoutube: serializer.fromJson<bool>(json['isYoutube']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookmark': serializer.toJson<String>(bookmark),
      'displayName': serializer.toJson<String>(displayName),
      'pathHint': serializer.toJson<String>(pathHint),
      'isYoutube': serializer.toJson<bool>(isYoutube),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  Folder copyWith({
    int? id,
    String? bookmark,
    String? displayName,
    String? pathHint,
    bool? isYoutube,
    DateTime? addedAt,
  }) => Folder(
    id: id ?? this.id,
    bookmark: bookmark ?? this.bookmark,
    displayName: displayName ?? this.displayName,
    pathHint: pathHint ?? this.pathHint,
    isYoutube: isYoutube ?? this.isYoutube,
    addedAt: addedAt ?? this.addedAt,
  );
  Folder copyWithCompanion(FoldersCompanion data) {
    return Folder(
      id: data.id.present ? data.id.value : this.id,
      bookmark: data.bookmark.present ? data.bookmark.value : this.bookmark,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      pathHint: data.pathHint.present ? data.pathHint.value : this.pathHint,
      isYoutube: data.isYoutube.present ? data.isYoutube.value : this.isYoutube,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Folder(')
          ..write('id: $id, ')
          ..write('bookmark: $bookmark, ')
          ..write('displayName: $displayName, ')
          ..write('pathHint: $pathHint, ')
          ..write('isYoutube: $isYoutube, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, bookmark, displayName, pathHint, isYoutube, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Folder &&
          other.id == this.id &&
          other.bookmark == this.bookmark &&
          other.displayName == this.displayName &&
          other.pathHint == this.pathHint &&
          other.isYoutube == this.isYoutube &&
          other.addedAt == this.addedAt);
}

class FoldersCompanion extends UpdateCompanion<Folder> {
  final Value<int> id;
  final Value<String> bookmark;
  final Value<String> displayName;
  final Value<String> pathHint;
  final Value<bool> isYoutube;
  final Value<DateTime> addedAt;
  const FoldersCompanion({
    this.id = const Value.absent(),
    this.bookmark = const Value.absent(),
    this.displayName = const Value.absent(),
    this.pathHint = const Value.absent(),
    this.isYoutube = const Value.absent(),
    this.addedAt = const Value.absent(),
  });
  FoldersCompanion.insert({
    this.id = const Value.absent(),
    required String bookmark,
    required String displayName,
    this.pathHint = const Value.absent(),
    this.isYoutube = const Value.absent(),
    this.addedAt = const Value.absent(),
  }) : bookmark = Value(bookmark),
       displayName = Value(displayName);
  static Insertable<Folder> custom({
    Expression<int>? id,
    Expression<String>? bookmark,
    Expression<String>? displayName,
    Expression<String>? pathHint,
    Expression<bool>? isYoutube,
    Expression<DateTime>? addedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookmark != null) 'bookmark': bookmark,
      if (displayName != null) 'display_name': displayName,
      if (pathHint != null) 'path_hint': pathHint,
      if (isYoutube != null) 'is_youtube': isYoutube,
      if (addedAt != null) 'added_at': addedAt,
    });
  }

  FoldersCompanion copyWith({
    Value<int>? id,
    Value<String>? bookmark,
    Value<String>? displayName,
    Value<String>? pathHint,
    Value<bool>? isYoutube,
    Value<DateTime>? addedAt,
  }) {
    return FoldersCompanion(
      id: id ?? this.id,
      bookmark: bookmark ?? this.bookmark,
      displayName: displayName ?? this.displayName,
      pathHint: pathHint ?? this.pathHint,
      isYoutube: isYoutube ?? this.isYoutube,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookmark.present) {
      map['bookmark'] = Variable<String>(bookmark.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (pathHint.present) {
      map['path_hint'] = Variable<String>(pathHint.value);
    }
    if (isYoutube.present) {
      map['is_youtube'] = Variable<bool>(isYoutube.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FoldersCompanion(')
          ..write('id: $id, ')
          ..write('bookmark: $bookmark, ')
          ..write('displayName: $displayName, ')
          ..write('pathHint: $pathHint, ')
          ..write('isYoutube: $isYoutube, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }
}

class $TracksTable extends Tracks with TableInfo<$TracksTable, Track> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TracksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _folderIdMeta = const VerificationMeta(
    'folderId',
  );
  @override
  late final GeneratedColumn<int> folderId = GeneratedColumn<int>(
    'folder_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES folders (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _relativePathMeta = const VerificationMeta(
    'relativePath',
  );
  @override
  late final GeneratedColumn<String> relativePath = GeneratedColumn<String>(
    'relative_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverPathMeta = const VerificationMeta(
    'coverPath',
  );
  @override
  late final GeneratedColumn<String> coverPath = GeneratedColumn<String>(
    'cover_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _searchTextMeta = const VerificationMeta(
    'searchText',
  );
  @override
  late final GeneratedColumn<String> searchText = GeneratedColumn<String>(
    'search_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TrackSource, int> source =
      GeneratedColumn<int>(
        'source',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<TrackSource>($TracksTable.$convertersource);
  static const VerificationMeta _youtubeIdMeta = const VerificationMeta(
    'youtubeId',
  );
  @override
  late final GeneratedColumn<String> youtubeId = GeneratedColumn<String>(
    'youtube_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSeenAtMeta = const VerificationMeta(
    'lastSeenAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSeenAt = GeneratedColumn<DateTime>(
    'last_seen_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    folderId,
    relativePath,
    fileName,
    title,
    artist,
    durationMs,
    coverPath,
    searchText,
    source,
    youtubeId,
    lastSeenAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tracks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Track> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('folder_id')) {
      context.handle(
        _folderIdMeta,
        folderId.isAcceptableOrUnknown(data['folder_id']!, _folderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_folderIdMeta);
    }
    if (data.containsKey('relative_path')) {
      context.handle(
        _relativePathMeta,
        relativePath.isAcceptableOrUnknown(
          data['relative_path']!,
          _relativePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_relativePathMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('cover_path')) {
      context.handle(
        _coverPathMeta,
        coverPath.isAcceptableOrUnknown(data['cover_path']!, _coverPathMeta),
      );
    }
    if (data.containsKey('search_text')) {
      context.handle(
        _searchTextMeta,
        searchText.isAcceptableOrUnknown(data['search_text']!, _searchTextMeta),
      );
    } else if (isInserting) {
      context.missing(_searchTextMeta);
    }
    if (data.containsKey('youtube_id')) {
      context.handle(
        _youtubeIdMeta,
        youtubeId.isAcceptableOrUnknown(data['youtube_id']!, _youtubeIdMeta),
      );
    }
    if (data.containsKey('last_seen_at')) {
      context.handle(
        _lastSeenAtMeta,
        lastSeenAt.isAcceptableOrUnknown(
          data['last_seen_at']!,
          _lastSeenAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastSeenAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {folderId, relativePath},
  ];
  @override
  Track map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Track(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      folderId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}folder_id'],
      )!,
      relativePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relative_path'],
      )!,
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      coverPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_path'],
      ),
      searchText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}search_text'],
      )!,
      source: $TracksTable.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}source'],
        )!,
      ),
      youtubeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}youtube_id'],
      ),
      lastSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_seen_at'],
      )!,
    );
  }

  @override
  $TracksTable createAlias(String alias) {
    return $TracksTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TrackSource, int, int> $convertersource =
      const EnumIndexConverter<TrackSource>(TrackSource.values);
}

class Track extends DataClass implements Insertable<Track> {
  final int id;
  final int folderId;

  /// Path relative to the folder root, always with `/` separators.
  final String relativePath;
  final String fileName;
  final String title;
  final String? artist;
  final int? durationMs;

  /// Cover image path relative to the app support directory.
  final String? coverPath;

  /// Lower-case, diacritic-free text used by search.
  final String searchText;
  final TrackSource source;
  final String? youtubeId;
  final DateTime lastSeenAt;
  const Track({
    required this.id,
    required this.folderId,
    required this.relativePath,
    required this.fileName,
    required this.title,
    this.artist,
    this.durationMs,
    this.coverPath,
    required this.searchText,
    required this.source,
    this.youtubeId,
    required this.lastSeenAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['folder_id'] = Variable<int>(folderId);
    map['relative_path'] = Variable<String>(relativePath);
    map['file_name'] = Variable<String>(fileName);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || artist != null) {
      map['artist'] = Variable<String>(artist);
    }
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    if (!nullToAbsent || coverPath != null) {
      map['cover_path'] = Variable<String>(coverPath);
    }
    map['search_text'] = Variable<String>(searchText);
    {
      map['source'] = Variable<int>(
        $TracksTable.$convertersource.toSql(source),
      );
    }
    if (!nullToAbsent || youtubeId != null) {
      map['youtube_id'] = Variable<String>(youtubeId);
    }
    map['last_seen_at'] = Variable<DateTime>(lastSeenAt);
    return map;
  }

  TracksCompanion toCompanion(bool nullToAbsent) {
    return TracksCompanion(
      id: Value(id),
      folderId: Value(folderId),
      relativePath: Value(relativePath),
      fileName: Value(fileName),
      title: Value(title),
      artist: artist == null && nullToAbsent
          ? const Value.absent()
          : Value(artist),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      coverPath: coverPath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverPath),
      searchText: Value(searchText),
      source: Value(source),
      youtubeId: youtubeId == null && nullToAbsent
          ? const Value.absent()
          : Value(youtubeId),
      lastSeenAt: Value(lastSeenAt),
    );
  }

  factory Track.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Track(
      id: serializer.fromJson<int>(json['id']),
      folderId: serializer.fromJson<int>(json['folderId']),
      relativePath: serializer.fromJson<String>(json['relativePath']),
      fileName: serializer.fromJson<String>(json['fileName']),
      title: serializer.fromJson<String>(json['title']),
      artist: serializer.fromJson<String?>(json['artist']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      coverPath: serializer.fromJson<String?>(json['coverPath']),
      searchText: serializer.fromJson<String>(json['searchText']),
      source: $TracksTable.$convertersource.fromJson(
        serializer.fromJson<int>(json['source']),
      ),
      youtubeId: serializer.fromJson<String?>(json['youtubeId']),
      lastSeenAt: serializer.fromJson<DateTime>(json['lastSeenAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'folderId': serializer.toJson<int>(folderId),
      'relativePath': serializer.toJson<String>(relativePath),
      'fileName': serializer.toJson<String>(fileName),
      'title': serializer.toJson<String>(title),
      'artist': serializer.toJson<String?>(artist),
      'durationMs': serializer.toJson<int?>(durationMs),
      'coverPath': serializer.toJson<String?>(coverPath),
      'searchText': serializer.toJson<String>(searchText),
      'source': serializer.toJson<int>(
        $TracksTable.$convertersource.toJson(source),
      ),
      'youtubeId': serializer.toJson<String?>(youtubeId),
      'lastSeenAt': serializer.toJson<DateTime>(lastSeenAt),
    };
  }

  Track copyWith({
    int? id,
    int? folderId,
    String? relativePath,
    String? fileName,
    String? title,
    Value<String?> artist = const Value.absent(),
    Value<int?> durationMs = const Value.absent(),
    Value<String?> coverPath = const Value.absent(),
    String? searchText,
    TrackSource? source,
    Value<String?> youtubeId = const Value.absent(),
    DateTime? lastSeenAt,
  }) => Track(
    id: id ?? this.id,
    folderId: folderId ?? this.folderId,
    relativePath: relativePath ?? this.relativePath,
    fileName: fileName ?? this.fileName,
    title: title ?? this.title,
    artist: artist.present ? artist.value : this.artist,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    coverPath: coverPath.present ? coverPath.value : this.coverPath,
    searchText: searchText ?? this.searchText,
    source: source ?? this.source,
    youtubeId: youtubeId.present ? youtubeId.value : this.youtubeId,
    lastSeenAt: lastSeenAt ?? this.lastSeenAt,
  );
  Track copyWithCompanion(TracksCompanion data) {
    return Track(
      id: data.id.present ? data.id.value : this.id,
      folderId: data.folderId.present ? data.folderId.value : this.folderId,
      relativePath: data.relativePath.present
          ? data.relativePath.value
          : this.relativePath,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      title: data.title.present ? data.title.value : this.title,
      artist: data.artist.present ? data.artist.value : this.artist,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      coverPath: data.coverPath.present ? data.coverPath.value : this.coverPath,
      searchText: data.searchText.present
          ? data.searchText.value
          : this.searchText,
      source: data.source.present ? data.source.value : this.source,
      youtubeId: data.youtubeId.present ? data.youtubeId.value : this.youtubeId,
      lastSeenAt: data.lastSeenAt.present
          ? data.lastSeenAt.value
          : this.lastSeenAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Track(')
          ..write('id: $id, ')
          ..write('folderId: $folderId, ')
          ..write('relativePath: $relativePath, ')
          ..write('fileName: $fileName, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('durationMs: $durationMs, ')
          ..write('coverPath: $coverPath, ')
          ..write('searchText: $searchText, ')
          ..write('source: $source, ')
          ..write('youtubeId: $youtubeId, ')
          ..write('lastSeenAt: $lastSeenAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    folderId,
    relativePath,
    fileName,
    title,
    artist,
    durationMs,
    coverPath,
    searchText,
    source,
    youtubeId,
    lastSeenAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Track &&
          other.id == this.id &&
          other.folderId == this.folderId &&
          other.relativePath == this.relativePath &&
          other.fileName == this.fileName &&
          other.title == this.title &&
          other.artist == this.artist &&
          other.durationMs == this.durationMs &&
          other.coverPath == this.coverPath &&
          other.searchText == this.searchText &&
          other.source == this.source &&
          other.youtubeId == this.youtubeId &&
          other.lastSeenAt == this.lastSeenAt);
}

class TracksCompanion extends UpdateCompanion<Track> {
  final Value<int> id;
  final Value<int> folderId;
  final Value<String> relativePath;
  final Value<String> fileName;
  final Value<String> title;
  final Value<String?> artist;
  final Value<int?> durationMs;
  final Value<String?> coverPath;
  final Value<String> searchText;
  final Value<TrackSource> source;
  final Value<String?> youtubeId;
  final Value<DateTime> lastSeenAt;
  const TracksCompanion({
    this.id = const Value.absent(),
    this.folderId = const Value.absent(),
    this.relativePath = const Value.absent(),
    this.fileName = const Value.absent(),
    this.title = const Value.absent(),
    this.artist = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.coverPath = const Value.absent(),
    this.searchText = const Value.absent(),
    this.source = const Value.absent(),
    this.youtubeId = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
  });
  TracksCompanion.insert({
    this.id = const Value.absent(),
    required int folderId,
    required String relativePath,
    required String fileName,
    required String title,
    this.artist = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.coverPath = const Value.absent(),
    required String searchText,
    required TrackSource source,
    this.youtubeId = const Value.absent(),
    required DateTime lastSeenAt,
  }) : folderId = Value(folderId),
       relativePath = Value(relativePath),
       fileName = Value(fileName),
       title = Value(title),
       searchText = Value(searchText),
       source = Value(source),
       lastSeenAt = Value(lastSeenAt);
  static Insertable<Track> custom({
    Expression<int>? id,
    Expression<int>? folderId,
    Expression<String>? relativePath,
    Expression<String>? fileName,
    Expression<String>? title,
    Expression<String>? artist,
    Expression<int>? durationMs,
    Expression<String>? coverPath,
    Expression<String>? searchText,
    Expression<int>? source,
    Expression<String>? youtubeId,
    Expression<DateTime>? lastSeenAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (folderId != null) 'folder_id': folderId,
      if (relativePath != null) 'relative_path': relativePath,
      if (fileName != null) 'file_name': fileName,
      if (title != null) 'title': title,
      if (artist != null) 'artist': artist,
      if (durationMs != null) 'duration_ms': durationMs,
      if (coverPath != null) 'cover_path': coverPath,
      if (searchText != null) 'search_text': searchText,
      if (source != null) 'source': source,
      if (youtubeId != null) 'youtube_id': youtubeId,
      if (lastSeenAt != null) 'last_seen_at': lastSeenAt,
    });
  }

  TracksCompanion copyWith({
    Value<int>? id,
    Value<int>? folderId,
    Value<String>? relativePath,
    Value<String>? fileName,
    Value<String>? title,
    Value<String?>? artist,
    Value<int?>? durationMs,
    Value<String?>? coverPath,
    Value<String>? searchText,
    Value<TrackSource>? source,
    Value<String?>? youtubeId,
    Value<DateTime>? lastSeenAt,
  }) {
    return TracksCompanion(
      id: id ?? this.id,
      folderId: folderId ?? this.folderId,
      relativePath: relativePath ?? this.relativePath,
      fileName: fileName ?? this.fileName,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      durationMs: durationMs ?? this.durationMs,
      coverPath: coverPath ?? this.coverPath,
      searchText: searchText ?? this.searchText,
      source: source ?? this.source,
      youtubeId: youtubeId ?? this.youtubeId,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (folderId.present) {
      map['folder_id'] = Variable<int>(folderId.value);
    }
    if (relativePath.present) {
      map['relative_path'] = Variable<String>(relativePath.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (coverPath.present) {
      map['cover_path'] = Variable<String>(coverPath.value);
    }
    if (searchText.present) {
      map['search_text'] = Variable<String>(searchText.value);
    }
    if (source.present) {
      map['source'] = Variable<int>(
        $TracksTable.$convertersource.toSql(source.value),
      );
    }
    if (youtubeId.present) {
      map['youtube_id'] = Variable<String>(youtubeId.value);
    }
    if (lastSeenAt.present) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TracksCompanion(')
          ..write('id: $id, ')
          ..write('folderId: $folderId, ')
          ..write('relativePath: $relativePath, ')
          ..write('fileName: $fileName, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('durationMs: $durationMs, ')
          ..write('coverPath: $coverPath, ')
          ..write('searchText: $searchText, ')
          ..write('source: $source, ')
          ..write('youtubeId: $youtubeId, ')
          ..write('lastSeenAt: $lastSeenAt')
          ..write(')'))
        .toString();
  }
}

class $YoutubeHistoryTable extends YoutubeHistory
    with TableInfo<$YoutubeHistoryTable, YoutubeHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $YoutubeHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _videoIdMeta = const VerificationMeta(
    'videoId',
  );
  @override
  late final GeneratedColumn<String> videoId = GeneratedColumn<String>(
    'video_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _thumbnailUrlMeta = const VerificationMeta(
    'thumbnailUrl',
  );
  @override
  late final GeneratedColumn<String> thumbnailUrl = GeneratedColumn<String>(
    'thumbnail_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _downloadedTrackIdMeta = const VerificationMeta(
    'downloadedTrackId',
  );
  @override
  late final GeneratedColumn<int> downloadedTrackId = GeneratedColumn<int>(
    'downloaded_track_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    videoId,
    title,
    author,
    thumbnailUrl,
    durationMs,
    downloadedTrackId,
    addedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'youtube_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<YoutubeHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('video_id')) {
      context.handle(
        _videoIdMeta,
        videoId.isAcceptableOrUnknown(data['video_id']!, _videoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_videoIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('thumbnail_url')) {
      context.handle(
        _thumbnailUrlMeta,
        thumbnailUrl.isAcceptableOrUnknown(
          data['thumbnail_url']!,
          _thumbnailUrlMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_thumbnailUrlMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('downloaded_track_id')) {
      context.handle(
        _downloadedTrackIdMeta,
        downloadedTrackId.isAcceptableOrUnknown(
          data['downloaded_track_id']!,
          _downloadedTrackIdMeta,
        ),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  YoutubeHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return YoutubeHistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      videoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}video_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      )!,
      thumbnailUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_url'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      downloadedTrackId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}downloaded_track_id'],
      ),
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $YoutubeHistoryTable createAlias(String alias) {
    return $YoutubeHistoryTable(attachedDatabase, alias);
  }
}

class YoutubeHistoryData extends DataClass
    implements Insertable<YoutubeHistoryData> {
  final int id;
  final String videoId;
  final String title;
  final String author;
  final String thumbnailUrl;
  final int? durationMs;
  final int? downloadedTrackId;
  final DateTime addedAt;
  const YoutubeHistoryData({
    required this.id,
    required this.videoId,
    required this.title,
    required this.author,
    required this.thumbnailUrl,
    this.durationMs,
    this.downloadedTrackId,
    required this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['video_id'] = Variable<String>(videoId);
    map['title'] = Variable<String>(title);
    map['author'] = Variable<String>(author);
    map['thumbnail_url'] = Variable<String>(thumbnailUrl);
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    if (!nullToAbsent || downloadedTrackId != null) {
      map['downloaded_track_id'] = Variable<int>(downloadedTrackId);
    }
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  YoutubeHistoryCompanion toCompanion(bool nullToAbsent) {
    return YoutubeHistoryCompanion(
      id: Value(id),
      videoId: Value(videoId),
      title: Value(title),
      author: Value(author),
      thumbnailUrl: Value(thumbnailUrl),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      downloadedTrackId: downloadedTrackId == null && nullToAbsent
          ? const Value.absent()
          : Value(downloadedTrackId),
      addedAt: Value(addedAt),
    );
  }

  factory YoutubeHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return YoutubeHistoryData(
      id: serializer.fromJson<int>(json['id']),
      videoId: serializer.fromJson<String>(json['videoId']),
      title: serializer.fromJson<String>(json['title']),
      author: serializer.fromJson<String>(json['author']),
      thumbnailUrl: serializer.fromJson<String>(json['thumbnailUrl']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      downloadedTrackId: serializer.fromJson<int?>(json['downloadedTrackId']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'videoId': serializer.toJson<String>(videoId),
      'title': serializer.toJson<String>(title),
      'author': serializer.toJson<String>(author),
      'thumbnailUrl': serializer.toJson<String>(thumbnailUrl),
      'durationMs': serializer.toJson<int?>(durationMs),
      'downloadedTrackId': serializer.toJson<int?>(downloadedTrackId),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  YoutubeHistoryData copyWith({
    int? id,
    String? videoId,
    String? title,
    String? author,
    String? thumbnailUrl,
    Value<int?> durationMs = const Value.absent(),
    Value<int?> downloadedTrackId = const Value.absent(),
    DateTime? addedAt,
  }) => YoutubeHistoryData(
    id: id ?? this.id,
    videoId: videoId ?? this.videoId,
    title: title ?? this.title,
    author: author ?? this.author,
    thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    downloadedTrackId: downloadedTrackId.present
        ? downloadedTrackId.value
        : this.downloadedTrackId,
    addedAt: addedAt ?? this.addedAt,
  );
  YoutubeHistoryData copyWithCompanion(YoutubeHistoryCompanion data) {
    return YoutubeHistoryData(
      id: data.id.present ? data.id.value : this.id,
      videoId: data.videoId.present ? data.videoId.value : this.videoId,
      title: data.title.present ? data.title.value : this.title,
      author: data.author.present ? data.author.value : this.author,
      thumbnailUrl: data.thumbnailUrl.present
          ? data.thumbnailUrl.value
          : this.thumbnailUrl,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      downloadedTrackId: data.downloadedTrackId.present
          ? data.downloadedTrackId.value
          : this.downloadedTrackId,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('YoutubeHistoryData(')
          ..write('id: $id, ')
          ..write('videoId: $videoId, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('durationMs: $durationMs, ')
          ..write('downloadedTrackId: $downloadedTrackId, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    videoId,
    title,
    author,
    thumbnailUrl,
    durationMs,
    downloadedTrackId,
    addedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is YoutubeHistoryData &&
          other.id == this.id &&
          other.videoId == this.videoId &&
          other.title == this.title &&
          other.author == this.author &&
          other.thumbnailUrl == this.thumbnailUrl &&
          other.durationMs == this.durationMs &&
          other.downloadedTrackId == this.downloadedTrackId &&
          other.addedAt == this.addedAt);
}

class YoutubeHistoryCompanion extends UpdateCompanion<YoutubeHistoryData> {
  final Value<int> id;
  final Value<String> videoId;
  final Value<String> title;
  final Value<String> author;
  final Value<String> thumbnailUrl;
  final Value<int?> durationMs;
  final Value<int?> downloadedTrackId;
  final Value<DateTime> addedAt;
  const YoutubeHistoryCompanion({
    this.id = const Value.absent(),
    this.videoId = const Value.absent(),
    this.title = const Value.absent(),
    this.author = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.downloadedTrackId = const Value.absent(),
    this.addedAt = const Value.absent(),
  });
  YoutubeHistoryCompanion.insert({
    this.id = const Value.absent(),
    required String videoId,
    required String title,
    this.author = const Value.absent(),
    required String thumbnailUrl,
    this.durationMs = const Value.absent(),
    this.downloadedTrackId = const Value.absent(),
    this.addedAt = const Value.absent(),
  }) : videoId = Value(videoId),
       title = Value(title),
       thumbnailUrl = Value(thumbnailUrl);
  static Insertable<YoutubeHistoryData> custom({
    Expression<int>? id,
    Expression<String>? videoId,
    Expression<String>? title,
    Expression<String>? author,
    Expression<String>? thumbnailUrl,
    Expression<int>? durationMs,
    Expression<int>? downloadedTrackId,
    Expression<DateTime>? addedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (videoId != null) 'video_id': videoId,
      if (title != null) 'title': title,
      if (author != null) 'author': author,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (durationMs != null) 'duration_ms': durationMs,
      if (downloadedTrackId != null) 'downloaded_track_id': downloadedTrackId,
      if (addedAt != null) 'added_at': addedAt,
    });
  }

  YoutubeHistoryCompanion copyWith({
    Value<int>? id,
    Value<String>? videoId,
    Value<String>? title,
    Value<String>? author,
    Value<String>? thumbnailUrl,
    Value<int?>? durationMs,
    Value<int?>? downloadedTrackId,
    Value<DateTime>? addedAt,
  }) {
    return YoutubeHistoryCompanion(
      id: id ?? this.id,
      videoId: videoId ?? this.videoId,
      title: title ?? this.title,
      author: author ?? this.author,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      durationMs: durationMs ?? this.durationMs,
      downloadedTrackId: downloadedTrackId ?? this.downloadedTrackId,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (videoId.present) {
      map['video_id'] = Variable<String>(videoId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (thumbnailUrl.present) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (downloadedTrackId.present) {
      map['downloaded_track_id'] = Variable<int>(downloadedTrackId.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('YoutubeHistoryCompanion(')
          ..write('id: $id, ')
          ..write('videoId: $videoId, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('durationMs: $durationMs, ')
          ..write('downloadedTrackId: $downloadedTrackId, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }
}

class $PlayerStatesTable extends PlayerStates
    with TableInfo<$PlayerStatesTable, PlayerState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayerStatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<String> json = GeneratedColumn<String>(
    'json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, json];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'player_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlayerState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('json')) {
      context.handle(
        _jsonMeta,
        json.isAcceptableOrUnknown(data['json']!, _jsonMeta),
      );
    } else if (isInserting) {
      context.missing(_jsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlayerState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlayerState(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      json: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json'],
      )!,
    );
  }

  @override
  $PlayerStatesTable createAlias(String alias) {
    return $PlayerStatesTable(attachedDatabase, alias);
  }
}

class PlayerState extends DataClass implements Insertable<PlayerState> {
  final int id;
  final String json;
  const PlayerState({required this.id, required this.json});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['json'] = Variable<String>(json);
    return map;
  }

  PlayerStatesCompanion toCompanion(bool nullToAbsent) {
    return PlayerStatesCompanion(id: Value(id), json: Value(json));
  }

  factory PlayerState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlayerState(
      id: serializer.fromJson<int>(json['id']),
      json: serializer.fromJson<String>(json['json']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'json': serializer.toJson<String>(json),
    };
  }

  PlayerState copyWith({int? id, String? json}) =>
      PlayerState(id: id ?? this.id, json: json ?? this.json);
  PlayerState copyWithCompanion(PlayerStatesCompanion data) {
    return PlayerState(
      id: data.id.present ? data.id.value : this.id,
      json: data.json.present ? data.json.value : this.json,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlayerState(')
          ..write('id: $id, ')
          ..write('json: $json')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, json);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlayerState && other.id == this.id && other.json == this.json);
}

class PlayerStatesCompanion extends UpdateCompanion<PlayerState> {
  final Value<int> id;
  final Value<String> json;
  const PlayerStatesCompanion({
    this.id = const Value.absent(),
    this.json = const Value.absent(),
  });
  PlayerStatesCompanion.insert({
    this.id = const Value.absent(),
    required String json,
  }) : json = Value(json);
  static Insertable<PlayerState> custom({
    Expression<int>? id,
    Expression<String>? json,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (json != null) 'json': json,
    });
  }

  PlayerStatesCompanion copyWith({Value<int>? id, Value<String>? json}) {
    return PlayerStatesCompanion(id: id ?? this.id, json: json ?? this.json);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (json.present) {
      map['json'] = Variable<String>(json.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayerStatesCompanion(')
          ..write('id: $id, ')
          ..write('json: $json')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FoldersTable folders = $FoldersTable(this);
  late final $TracksTable tracks = $TracksTable(this);
  late final $YoutubeHistoryTable youtubeHistory = $YoutubeHistoryTable(this);
  late final $PlayerStatesTable playerStates = $PlayerStatesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    folders,
    tracks,
    youtubeHistory,
    playerStates,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'folders',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tracks', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$FoldersTableCreateCompanionBuilder = FoldersCompanion Function({
  Value<int> id,
  required String bookmark,
  required String displayName,
  Value<String> pathHint,
  Value<bool> isYoutube,
  Value<DateTime> addedAt,
});
typedef $$FoldersTableUpdateCompanionBuilder = FoldersCompanion Function({
  Value<int> id,
  Value<String> bookmark,
  Value<String> displayName,
  Value<String> pathHint,
  Value<bool> isYoutube,
  Value<DateTime> addedAt,
});

final class $$FoldersTableReferences
    extends BaseReferences<_$AppDatabase, $FoldersTable, Folder> {
  $$FoldersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TracksTable, List<Track>> _tracksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.tracks,
    aliasName: 'folders__id__tracks__folder_id',
  );

  $$TracksTableProcessedTableManager get tracksRefs {
    final manager = $$TracksTableTableManager(
      $_db,
      $_db.tracks,
    ).filter((f) => f.folderId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_tracksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FoldersTableFilterComposer
    extends Composer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookmark => $composableBuilder(
    column: $table.bookmark,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pathHint => $composableBuilder(
    column: $table.pathHint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isYoutube => $composableBuilder(
    column: $table.isYoutube,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> tracksRefs(
    Expression<bool> Function($$TracksTableFilterComposer f) f,
  ) {
    final $$TracksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.folderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableFilterComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FoldersTableOrderingComposer
    extends Composer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookmark => $composableBuilder(
    column: $table.bookmark,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pathHint => $composableBuilder(
    column: $table.pathHint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isYoutube => $composableBuilder(
    column: $table.isYoutube,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FoldersTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get bookmark =>
      $composableBuilder(column: $table.bookmark, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pathHint =>
      $composableBuilder(column: $table.pathHint, builder: (column) => column);

  GeneratedColumn<bool> get isYoutube =>
      $composableBuilder(column: $table.isYoutube, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  Expression<T> tracksRefs<T extends Object>(
    Expression<T> Function($$TracksTableAnnotationComposer a) f,
  ) {
    final $$TracksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tracks,
      getReferencedColumn: (t) => t.folderId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TracksTableAnnotationComposer(
            $db: $db,
            $table: $db.tracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FoldersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FoldersTable,
          Folder,
          $$FoldersTableFilterComposer,
          $$FoldersTableOrderingComposer,
          $$FoldersTableAnnotationComposer,
          $$FoldersTableCreateCompanionBuilder,
          $$FoldersTableUpdateCompanionBuilder,
          (Folder, $$FoldersTableReferences),
          Folder,
          PrefetchHooks Function({bool tracksRefs})
        > {
  $$FoldersTableTableManager(_$AppDatabase db, $FoldersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoldersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoldersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoldersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> bookmark = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> pathHint = const Value.absent(),
                Value<bool> isYoutube = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
              }) => FoldersCompanion(
                id: id,
                bookmark: bookmark,
                displayName: displayName,
                pathHint: pathHint,
                isYoutube: isYoutube,
                addedAt: addedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String bookmark,
                required String displayName,
                Value<String> pathHint = const Value.absent(),
                Value<bool> isYoutube = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
              }) => FoldersCompanion.insert(
                id: id,
                bookmark: bookmark,
                displayName: displayName,
                pathHint: pathHint,
                isYoutube: isYoutube,
                addedAt: addedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FoldersTable, Folder>(table),
                  $$FoldersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tracksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (tracksRefs) db.tracks],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tracksRefs)
                    await $_getPrefetchedData<Folder, $FoldersTable, Track>(
                      currentTable: table,
                      referencedTable: $$FoldersTableReferences
                          ._tracksRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$FoldersTableReferences(db, table, p0).tracksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.folderId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$FoldersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FoldersTable,
      Folder,
      $$FoldersTableFilterComposer,
      $$FoldersTableOrderingComposer,
      $$FoldersTableAnnotationComposer,
      $$FoldersTableCreateCompanionBuilder,
      $$FoldersTableUpdateCompanionBuilder,
      (Folder, $$FoldersTableReferences),
      Folder,
      PrefetchHooks Function({bool tracksRefs})
    >;
typedef $$TracksTableCreateCompanionBuilder = TracksCompanion Function({
  Value<int> id,
  required int folderId,
  required String relativePath,
  required String fileName,
  required String title,
  Value<String?> artist,
  Value<int?> durationMs,
  Value<String?> coverPath,
  required String searchText,
  required TrackSource source,
  Value<String?> youtubeId,
  required DateTime lastSeenAt,
});
typedef $$TracksTableUpdateCompanionBuilder = TracksCompanion Function({
  Value<int> id,
  Value<int> folderId,
  Value<String> relativePath,
  Value<String> fileName,
  Value<String> title,
  Value<String?> artist,
  Value<int?> durationMs,
  Value<String?> coverPath,
  Value<String> searchText,
  Value<TrackSource> source,
  Value<String?> youtubeId,
  Value<DateTime> lastSeenAt,
});

final class $$TracksTableReferences
    extends BaseReferences<_$AppDatabase, $TracksTable, Track> {
  $$TracksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $FoldersTable _folderIdTable(_$AppDatabase db) =>
      db.folders.createAlias('tracks__folder_id__folders__id');

  $$FoldersTableProcessedTableManager get folderId {
    final $_column = $_itemColumn<int>('folder_id')!;

    final manager = $$FoldersTableTableManager(
      $_db,
      $_db.folders,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_folderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TracksTableFilterComposer
    extends Composer<_$AppDatabase, $TracksTable> {
  $$TracksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverPath => $composableBuilder(
    column: $table.coverPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TrackSource, TrackSource, int> get source =>
      $composableBuilder(
        column: $table.source,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get youtubeId => $composableBuilder(
    column: $table.youtubeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  $$FoldersTableFilterComposer get folderId {
    final $$FoldersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableFilterComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TracksTableOrderingComposer
    extends Composer<_$AppDatabase, $TracksTable> {
  $$TracksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverPath => $composableBuilder(
    column: $table.coverPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get youtubeId => $composableBuilder(
    column: $table.youtubeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$FoldersTableOrderingComposer get folderId {
    final $$FoldersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableOrderingComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TracksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TracksTable> {
  $$TracksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverPath =>
      $composableBuilder(column: $table.coverPath, builder: (column) => column);

  GeneratedColumn<String> get searchText => $composableBuilder(
    column: $table.searchText,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<TrackSource, int> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get youtubeId =>
      $composableBuilder(column: $table.youtubeId, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => column,
  );

  $$FoldersTableAnnotationComposer get folderId {
    final $$FoldersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderId,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableAnnotationComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TracksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TracksTable,
          Track,
          $$TracksTableFilterComposer,
          $$TracksTableOrderingComposer,
          $$TracksTableAnnotationComposer,
          $$TracksTableCreateCompanionBuilder,
          $$TracksTableUpdateCompanionBuilder,
          (Track, $$TracksTableReferences),
          Track,
          PrefetchHooks Function({bool folderId})
        > {
  $$TracksTableTableManager(_$AppDatabase db, $TracksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TracksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TracksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TracksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> folderId = const Value.absent(),
                Value<String> relativePath = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> artist = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<String?> coverPath = const Value.absent(),
                Value<String> searchText = const Value.absent(),
                Value<TrackSource> source = const Value.absent(),
                Value<String?> youtubeId = const Value.absent(),
                Value<DateTime> lastSeenAt = const Value.absent(),
              }) => TracksCompanion(
                id: id,
                folderId: folderId,
                relativePath: relativePath,
                fileName: fileName,
                title: title,
                artist: artist,
                durationMs: durationMs,
                coverPath: coverPath,
                searchText: searchText,
                source: source,
                youtubeId: youtubeId,
                lastSeenAt: lastSeenAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int folderId,
                required String relativePath,
                required String fileName,
                required String title,
                Value<String?> artist = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<String?> coverPath = const Value.absent(),
                required String searchText,
                required TrackSource source,
                Value<String?> youtubeId = const Value.absent(),
                required DateTime lastSeenAt,
              }) => TracksCompanion.insert(
                id: id,
                folderId: folderId,
                relativePath: relativePath,
                fileName: fileName,
                title: title,
                artist: artist,
                durationMs: durationMs,
                coverPath: coverPath,
                searchText: searchText,
                source: source,
                youtubeId: youtubeId,
                lastSeenAt: lastSeenAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TracksTable, Track>(table),
                  $$TracksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({folderId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (folderId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.folderId,
                        referencedTable: $$TracksTableReferences._folderIdTable(
                          db,
                        ),
                        referencedColumn: $$TracksTableReferences
                            ._folderIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TracksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TracksTable,
      Track,
      $$TracksTableFilterComposer,
      $$TracksTableOrderingComposer,
      $$TracksTableAnnotationComposer,
      $$TracksTableCreateCompanionBuilder,
      $$TracksTableUpdateCompanionBuilder,
      (Track, $$TracksTableReferences),
      Track,
      PrefetchHooks Function({bool folderId})
    >;
typedef $$YoutubeHistoryTableCreateCompanionBuilder =
    YoutubeHistoryCompanion Function({
      Value<int> id,
      required String videoId,
      required String title,
      Value<String> author,
      required String thumbnailUrl,
      Value<int?> durationMs,
      Value<int?> downloadedTrackId,
      Value<DateTime> addedAt,
    });
typedef $$YoutubeHistoryTableUpdateCompanionBuilder =
    YoutubeHistoryCompanion Function({
      Value<int> id,
      Value<String> videoId,
      Value<String> title,
      Value<String> author,
      Value<String> thumbnailUrl,
      Value<int?> durationMs,
      Value<int?> downloadedTrackId,
      Value<DateTime> addedAt,
    });

class $$YoutubeHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $YoutubeHistoryTable> {
  $$YoutubeHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get videoId => $composableBuilder(
    column: $table.videoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get downloadedTrackId => $composableBuilder(
    column: $table.downloadedTrackId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$YoutubeHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $YoutubeHistoryTable> {
  $$YoutubeHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get videoId => $composableBuilder(
    column: $table.videoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get downloadedTrackId => $composableBuilder(
    column: $table.downloadedTrackId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$YoutubeHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $YoutubeHistoryTable> {
  $$YoutubeHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get videoId =>
      $composableBuilder(column: $table.videoId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get downloadedTrackId => $composableBuilder(
    column: $table.downloadedTrackId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);
}

class $$YoutubeHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $YoutubeHistoryTable,
          YoutubeHistoryData,
          $$YoutubeHistoryTableFilterComposer,
          $$YoutubeHistoryTableOrderingComposer,
          $$YoutubeHistoryTableAnnotationComposer,
          $$YoutubeHistoryTableCreateCompanionBuilder,
          $$YoutubeHistoryTableUpdateCompanionBuilder,
          (
            YoutubeHistoryData,
            BaseReferences<
              _$AppDatabase,
              $YoutubeHistoryTable,
              YoutubeHistoryData
            >,
          ),
          YoutubeHistoryData,
          PrefetchHooks Function()
        > {
  $$YoutubeHistoryTableTableManager(
    _$AppDatabase db,
    $YoutubeHistoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$YoutubeHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$YoutubeHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$YoutubeHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> videoId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> author = const Value.absent(),
                Value<String> thumbnailUrl = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<int?> downloadedTrackId = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
              }) => YoutubeHistoryCompanion(
                id: id,
                videoId: videoId,
                title: title,
                author: author,
                thumbnailUrl: thumbnailUrl,
                durationMs: durationMs,
                downloadedTrackId: downloadedTrackId,
                addedAt: addedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String videoId,
                required String title,
                Value<String> author = const Value.absent(),
                required String thumbnailUrl,
                Value<int?> durationMs = const Value.absent(),
                Value<int?> downloadedTrackId = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
              }) => YoutubeHistoryCompanion.insert(
                id: id,
                videoId: videoId,
                title: title,
                author: author,
                thumbnailUrl: thumbnailUrl,
                durationMs: durationMs,
                downloadedTrackId: downloadedTrackId,
                addedAt: addedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$YoutubeHistoryTable, YoutubeHistoryData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $YoutubeHistoryTable,
                    YoutubeHistoryData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$YoutubeHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $YoutubeHistoryTable,
      YoutubeHistoryData,
      $$YoutubeHistoryTableFilterComposer,
      $$YoutubeHistoryTableOrderingComposer,
      $$YoutubeHistoryTableAnnotationComposer,
      $$YoutubeHistoryTableCreateCompanionBuilder,
      $$YoutubeHistoryTableUpdateCompanionBuilder,
      (
        YoutubeHistoryData,
        BaseReferences<_$AppDatabase, $YoutubeHistoryTable, YoutubeHistoryData>,
      ),
      YoutubeHistoryData,
      PrefetchHooks Function()
    >;
typedef $$PlayerStatesTableCreateCompanionBuilder =
    PlayerStatesCompanion Function({Value<int> id, required String json});
typedef $$PlayerStatesTableUpdateCompanionBuilder =
    PlayerStatesCompanion Function({Value<int> id, Value<String> json});

class $$PlayerStatesTableFilterComposer
    extends Composer<_$AppDatabase, $PlayerStatesTable> {
  $$PlayerStatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlayerStatesTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayerStatesTable> {
  $$PlayerStatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get json => $composableBuilder(
    column: $table.json,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlayerStatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayerStatesTable> {
  $$PlayerStatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get json =>
      $composableBuilder(column: $table.json, builder: (column) => column);
}

class $$PlayerStatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlayerStatesTable,
          PlayerState,
          $$PlayerStatesTableFilterComposer,
          $$PlayerStatesTableOrderingComposer,
          $$PlayerStatesTableAnnotationComposer,
          $$PlayerStatesTableCreateCompanionBuilder,
          $$PlayerStatesTableUpdateCompanionBuilder,
          (
            PlayerState,
            BaseReferences<_$AppDatabase, $PlayerStatesTable, PlayerState>,
          ),
          PlayerState,
          PrefetchHooks Function()
        > {
  $$PlayerStatesTableTableManager(_$AppDatabase db, $PlayerStatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayerStatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayerStatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayerStatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> json = const Value.absent(),
          }) => PlayerStatesCompanion(id: id, json: json),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String json,
          }) => PlayerStatesCompanion.insert(id: id, json: json),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlayerStatesTable, PlayerState>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PlayerStatesTable,
                    PlayerState
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlayerStatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlayerStatesTable,
      PlayerState,
      $$PlayerStatesTableFilterComposer,
      $$PlayerStatesTableOrderingComposer,
      $$PlayerStatesTableAnnotationComposer,
      $$PlayerStatesTableCreateCompanionBuilder,
      $$PlayerStatesTableUpdateCompanionBuilder,
      (
        PlayerState,
        BaseReferences<_$AppDatabase, $PlayerStatesTable, PlayerState>,
      ),
      PlayerState,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FoldersTableTableManager get folders =>
      $$FoldersTableTableManager(_db, _db.folders);
  $$TracksTableTableManager get tracks =>
      $$TracksTableTableManager(_db, _db.tracks);
  $$YoutubeHistoryTableTableManager get youtubeHistory =>
      $$YoutubeHistoryTableTableManager(_db, _db.youtubeHistory);
  $$PlayerStatesTableTableManager get playerStates =>
      $$PlayerStatesTableTableManager(_db, _db.playerStates);
}
