import 'dart:convert';

/// Why a [SyncPayload] failed to parse or apply.
enum SyncPayloadErrorReason {
  /// Not valid JSON, or missing/mistyped required fields.
  malformed,

  /// `format`/`formatVersion` isn't one this app version understands.
  unsupportedFormat,

  /// `schemaVersion` is newer than the local database's.
  newerSchema,
}

class SyncPayloadException implements Exception {
  const SyncPayloadException(this.reason, this.message);

  final SyncPayloadErrorReason reason;
  final String message;

  @override
  String toString() => 'SyncPayloadException($reason): $message';
}

/// Mirrors a `holds` row exactly (including [deleted], which the domain
/// [Hold][] model omits) so the merge engine can operate on it directly.
///
/// [Hold]: ../models/hold.dart
class SyncHoldRecord {
  const SyncHoldRecord({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.deviceId,
    required this.durationMs,
    this.contractionMs,
    required this.type,
    required this.lungVolume,
    this.prepMode,
    this.notes,
    required this.isPb,
    this.rating,
    required this.deleted,
    required this.tagIds,
  });

  final String id;
  final int createdAt;
  final int updatedAt;
  final String deviceId;
  final int durationMs;
  final int? contractionMs;
  final String type;
  final String lungVolume;
  final String? prepMode;
  final String? notes;
  final bool isPb;
  final int? rating;
  final bool deleted;
  final List<String> tagIds;

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'deviceId': deviceId,
    'durationMs': durationMs,
    'contractionMs': contractionMs,
    'type': type,
    'lungVolume': lungVolume,
    'prepMode': prepMode,
    'notes': notes,
    'isPb': isPb,
    'rating': rating,
    'deleted': deleted,
    'tagIds': tagIds,
  };

  factory SyncHoldRecord.fromJson(Map<String, dynamic> json) {
    return SyncHoldRecord(
      id: _requireString(json, 'id'),
      createdAt: _requireInt(json, 'createdAt'),
      updatedAt: _requireInt(json, 'updatedAt'),
      deviceId: _requireString(json, 'deviceId'),
      durationMs: _requireInt(json, 'durationMs'),
      contractionMs: _optionalInt(json, 'contractionMs'),
      type: _requireString(json, 'type'),
      lungVolume: _requireString(json, 'lungVolume'),
      prepMode: _optionalString(json, 'prepMode'),
      notes: _optionalString(json, 'notes'),
      isPb: json['isPb'] == true,
      rating: _optionalInt(json, 'rating'),
      deleted: json['deleted'] == true,
      tagIds: _requireStringList(json, 'tagIds'),
    );
  }
}

/// Mirrors a `table_sessions` row exactly. [roundDetails] is kept as the
/// raw JSON-encoded string already stored in the column — the merge engine
/// never inspects it, only carries it along with whichever row wins.
class SyncTableSessionRecord {
  const SyncTableSessionRecord({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.deviceId,
    required this.type,
    required this.basedOnMaxMs,
    required this.roundsTotal,
    required this.roundsCompleted,
    required this.roundDetails,
    required this.deleted,
  });

  final String id;
  final int createdAt;
  final int updatedAt;
  final String deviceId;
  final String type;
  final int basedOnMaxMs;
  final int roundsTotal;
  final int roundsCompleted;
  final String roundDetails;
  final bool deleted;

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'deviceId': deviceId,
    'type': type,
    'basedOnMaxMs': basedOnMaxMs,
    'roundsTotal': roundsTotal,
    'roundsCompleted': roundsCompleted,
    'roundDetails': roundDetails,
    'deleted': deleted,
  };

  factory SyncTableSessionRecord.fromJson(Map<String, dynamic> json) {
    return SyncTableSessionRecord(
      id: _requireString(json, 'id'),
      createdAt: _requireInt(json, 'createdAt'),
      updatedAt: _requireInt(json, 'updatedAt'),
      deviceId: _requireString(json, 'deviceId'),
      type: _requireString(json, 'type'),
      basedOnMaxMs: _requireInt(json, 'basedOnMaxMs'),
      roundsTotal: _requireInt(json, 'roundsTotal'),
      roundsCompleted: _requireInt(json, 'roundsCompleted'),
      roundDetails: _requireString(json, 'roundDetails'),
      deleted: json['deleted'] == true,
    );
  }
}

/// Mirrors an `imst_sessions` row exactly. Merged by the same id-keyed,
/// last-write-wins rule as holds — `device_id` is the tiebreak.
class SyncImstSessionRecord {
  const SyncImstSessionRecord({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.deviceId,
    required this.breaths,
    this.deviceName,
    this.deviceLevel,
    this.pimaxCmh2o,
    this.percentPimax,
    this.durationMs,
    required this.deleted,
  });

  final String id;
  final int createdAt;
  final int updatedAt;
  final String deviceId;
  final int breaths;
  final String? deviceName;
  final int? deviceLevel;
  final int? pimaxCmh2o;
  final int? percentPimax;
  final int? durationMs;
  final bool deleted;

  Map<String, dynamic> toJson() => {
    'id': id,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'deviceId': deviceId,
    'breaths': breaths,
    'deviceName': deviceName,
    'deviceLevel': deviceLevel,
    'pimaxCmh2o': pimaxCmh2o,
    'percentPimax': percentPimax,
    'durationMs': durationMs,
    'deleted': deleted,
  };

  factory SyncImstSessionRecord.fromJson(Map<String, dynamic> json) {
    return SyncImstSessionRecord(
      id: _requireString(json, 'id'),
      createdAt: _requireInt(json, 'createdAt'),
      updatedAt: _requireInt(json, 'updatedAt'),
      deviceId: _requireString(json, 'deviceId'),
      breaths: _requireInt(json, 'breaths'),
      deviceName: _optionalString(json, 'deviceName'),
      deviceLevel: _optionalInt(json, 'deviceLevel'),
      pimaxCmh2o: _optionalInt(json, 'pimaxCmh2o'),
      percentPimax: _optionalInt(json, 'percentPimax'),
      durationMs: _optionalInt(json, 'durationMs'),
      deleted: json['deleted'] == true,
    );
  }
}

/// Mirrors a `tags` row exactly. Unlike holds/table_sessions, the `tags`
/// table has no `device_id` column, so the merge engine's tiebreak for
/// this type falls back to `id` — see [SyncMergeService][].
///
/// [SyncMergeService]: ../services/sync_merge_service.dart
class SyncTagRecord {
  const SyncTagRecord({
    required this.id,
    required this.labelKey,
    required this.createdAt,
    required this.updatedAt,
    required this.deleted,
  });

  final String id;
  final String labelKey;
  final int createdAt;
  final int updatedAt;
  final bool deleted;

  Map<String, dynamic> toJson() => {
    'id': id,
    'labelKey': labelKey,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'deleted': deleted,
  };

  factory SyncTagRecord.fromJson(Map<String, dynamic> json) {
    return SyncTagRecord(
      id: _requireString(json, 'id'),
      labelKey: _requireString(json, 'labelKey'),
      createdAt: _requireInt(json, 'createdAt'),
      updatedAt: _requireInt(json, 'updatedAt'),
      deleted: json['deleted'] == true,
    );
  }
}

/// Versioned envelope for a full-state export/import of one device's data.
/// Doubles as the backup/restore file format — see `docs/phases/PHASE_2A_sync.md`.
class SyncPayload {
  const SyncPayload({
    required this.schemaVersion,
    required this.exportedAt,
    required this.deviceId,
    required this.deviceName,
    required this.appVersion,
    required this.holds,
    required this.tableSessions,
    this.imstSessions = const [],
    required this.tags,
  });

  static const format = 'breathlab-sync';
  static const formatVersion = 1;

  final int schemaVersion;
  final int exportedAt;
  final String deviceId;
  final String deviceName;
  final String appVersion;
  final List<SyncHoldRecord> holds;
  final List<SyncTableSessionRecord> tableSessions;
  final List<SyncImstSessionRecord> imstSessions;
  final List<SyncTagRecord> tags;

  String encode() => jsonEncode(toJson());

  Map<String, dynamic> toJson() => {
    'format': format,
    'formatVersion': formatVersion,
    'schemaVersion': schemaVersion,
    'exportedAt': exportedAt,
    'deviceId': deviceId,
    'deviceName': deviceName,
    'appVersion': appVersion,
    'holds': holds.map((h) => h.toJson()).toList(),
    'tableSessions': tableSessions.map((s) => s.toJson()).toList(),
    'imstSessions': imstSessions.map((s) => s.toJson()).toList(),
    'tags': tags.map((t) => t.toJson()).toList(),
  };

  /// Parses and structurally validates a payload. Does not check
  /// [schemaVersion] against the local database — the caller knows that
  /// version and can produce a more specific [SyncPayloadErrorReason.newerSchema]
  /// message than this codec can.
  factory SyncPayload.decode(String source) {
    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException catch (e) {
      throw SyncPayloadException(
        SyncPayloadErrorReason.malformed,
        'Not valid JSON: ${e.message}',
      );
    }
    if (decoded is! Map<String, dynamic>) {
      throw const SyncPayloadException(
        SyncPayloadErrorReason.malformed,
        'Top-level JSON value must be an object.',
      );
    }
    return SyncPayload.fromJson(decoded);
  }

  factory SyncPayload.fromJson(Map<String, dynamic> json) {
    if (json['format'] != format) {
      throw SyncPayloadException(
        SyncPayloadErrorReason.unsupportedFormat,
        'Not a BreathLab sync file.',
      );
    }
    final incomingFormatVersion = json['formatVersion'];
    if (incomingFormatVersion is! int ||
        incomingFormatVersion > formatVersion) {
      throw const SyncPayloadException(
        SyncPayloadErrorReason.unsupportedFormat,
        'This file was exported by a newer, incompatible version of BreathLab.',
      );
    }
    try {
      return SyncPayload(
        schemaVersion: _requireInt(json, 'schemaVersion'),
        exportedAt: _requireInt(json, 'exportedAt'),
        deviceId: _requireString(json, 'deviceId'),
        deviceName: _requireString(json, 'deviceName'),
        appVersion: _requireString(json, 'appVersion'),
        holds: _requireList(
          json,
          'holds',
        ).map((e) => SyncHoldRecord.fromJson(_asObject(e))).toList(),
        tableSessions: _requireList(
          json,
          'tableSessions',
        ).map((e) => SyncTableSessionRecord.fromJson(_asObject(e))).toList(),
        // Absent in schema-2 payloads, which a schema-3 build still accepts.
        imstSessions: _optionalList(
          json,
          'imstSessions',
        ).map((e) => SyncImstSessionRecord.fromJson(_asObject(e))).toList(),
        tags: _requireList(
          json,
          'tags',
        ).map((e) => SyncTagRecord.fromJson(_asObject(e))).toList(),
      );
    } on SyncPayloadException {
      rethrow;
    } catch (e) {
      throw SyncPayloadException(
        SyncPayloadErrorReason.malformed,
        'Malformed sync file: $e',
      );
    }
  }
}

Map<String, dynamic> _asObject(Object? value) {
  if (value is Map<String, dynamic>) return value;
  throw const SyncPayloadException(
    SyncPayloadErrorReason.malformed,
    'Expected a JSON object.',
  );
}

String _requireString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String) return value;
  throw SyncPayloadException(
    SyncPayloadErrorReason.malformed,
    'Missing or invalid field "$key".',
  );
}

String? _optionalString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is String) return value;
  throw SyncPayloadException(
    SyncPayloadErrorReason.malformed,
    'Invalid field "$key".',
  );
}

int _requireInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is int) return value;
  throw SyncPayloadException(
    SyncPayloadErrorReason.malformed,
    'Missing or invalid field "$key".',
  );
}

int? _optionalInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return null;
  if (value is int) return value;
  throw SyncPayloadException(
    SyncPayloadErrorReason.malformed,
    'Invalid field "$key".',
  );
}

List<Object?> _requireList(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is List) return value;
  throw SyncPayloadException(
    SyncPayloadErrorReason.malformed,
    'Missing or invalid field "$key".',
  );
}

/// Like [_requireList] but treats an absent key as an empty list. Used for
/// fields added in a later schema than some payloads on disk were written at.
List<Object?> _optionalList(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value == null) return const [];
  if (value is List) return value;
  throw SyncPayloadException(
    SyncPayloadErrorReason.malformed,
    'Invalid field "$key".',
  );
}

List<String> _requireStringList(Map<String, dynamic> json, String key) {
  return _requireList(json, key)
      .map(
        (e) => e is String
            ? e
            : throw SyncPayloadException(
                SyncPayloadErrorReason.malformed,
                'Invalid field "$key".',
              ),
      )
      .toList();
}
