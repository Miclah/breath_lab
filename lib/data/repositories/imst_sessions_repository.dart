import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/imst_session.dart';
import '../../domain/models/sync_payload.dart';
import '../db/app_database.dart' as db;
import '../db/database_provider.dart';
import 'device_id_provider.dart';

class ImstSessionsRepository {
  ImstSessionsRepository(this._db, this._deviceId);

  final db.AppDatabase _db;
  final String _deviceId;
  static const _uuid = Uuid();

  String newId() => _uuid.v4();

  Future<void> save(ImstSession session) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _db
        .into(_db.imstSessions)
        .insertOnConflictUpdate(
          db.ImstSessionsCompanion(
            id: Value(session.id),
            createdAt: Value(session.createdAt.millisecondsSinceEpoch),
            updatedAt: Value(now),
            deviceId: Value(_deviceId),
            breaths: Value(session.breaths),
            deviceName: Value(session.deviceName),
            deviceLevel: Value(session.deviceLevel),
            pimaxCmh2o: Value(session.pimaxCmH2O),
            percentPimax: Value(session.percentPimax),
            durationMs: Value(session.duration?.inMilliseconds),
            deleted: const Value(0),
          ),
        );
  }

  /// All non-deleted sessions, newest first.
  Future<List<ImstSession>> getAll() async {
    final rows =
        await (_db.select(_db.imstSessions)
              ..where((t) => t.deleted.equals(0))
              ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
            .get();
    return rows.map(_fromRow).toList();
  }

  /// Every row, soft-deleted included — for the sync payload.
  Future<List<SyncImstSessionRecord>> allSyncRecords() async {
    final rows = await _db.select(_db.imstSessions).get();
    return [
      for (final r in rows)
        SyncImstSessionRecord(
          id: r.id,
          createdAt: r.createdAt,
          updatedAt: r.updatedAt,
          deviceId: r.deviceId,
          breaths: r.breaths,
          deviceName: r.deviceName,
          deviceLevel: r.deviceLevel,
          pimaxCmh2o: r.pimaxCmh2o,
          percentPimax: r.percentPimax,
          durationMs: r.durationMs,
          deleted: r.deleted == 1,
        ),
    ];
  }

  Future<void> upsertAll(List<SyncImstSessionRecord> records) async {
    if (records.isEmpty) return;
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.imstSessions, [
        for (final r in records)
          db.ImstSessionsCompanion(
            id: Value(r.id),
            createdAt: Value(r.createdAt),
            updatedAt: Value(r.updatedAt),
            deviceId: Value(r.deviceId),
            breaths: Value(r.breaths),
            deviceName: Value(r.deviceName),
            deviceLevel: Value(r.deviceLevel),
            pimaxCmh2o: Value(r.pimaxCmh2o),
            percentPimax: Value(r.percentPimax),
            durationMs: Value(r.durationMs),
            deleted: Value(r.deleted ? 1 : 0),
          ),
      ]);
    });
  }

  ImstSession _fromRow(db.ImstSession row) {
    return ImstSession(
      id: row.id,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(row.updatedAt),
      deviceId: row.deviceId,
      breaths: row.breaths,
      deviceName: row.deviceName,
      deviceLevel: row.deviceLevel,
      pimaxCmH2O: row.pimaxCmh2o,
      percentPimax: row.percentPimax,
      duration: row.durationMs == null
          ? null
          : Duration(milliseconds: row.durationMs!),
    );
  }
}

final imstSessionsRepositoryProvider = FutureProvider<ImstSessionsRepository>((
  ref,
) async {
  final database = ref.watch(databaseProvider);
  final deviceId = await ref.watch(deviceIdProvider.future);
  return ImstSessionsRepository(database, deviceId);
});

/// All non-deleted IMST sessions, newest first.
final allImstSessionsProvider = FutureProvider<List<ImstSession>>((ref) async {
  final repo = await ref.watch(imstSessionsRepositoryProvider.future);
  return repo.getAll();
});
