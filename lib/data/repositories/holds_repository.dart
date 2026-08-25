import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../db/app_database.dart' as db;
import '../db/database_provider.dart';
import '../../domain/models/hold.dart';
import '../../domain/models/sync_payload.dart';
import 'device_id_provider.dart';

class HoldsRepository {
  HoldsRepository(this._db, this._deviceId);

  final db.AppDatabase _db;
  final String _deviceId;
  static const _uuid = Uuid();

  String newId() => _uuid.v4();

  /// Persists a hold and, for max holds, re-derives which one carries the PB.
  ///
  /// Returns the new best max-hold duration in ms, or null when the hold
  /// wasn't a max hold or none remain. [hold.isPb] as supplied by the caller
  /// is overwritten by [recomputePbFlags] — the flag is derived from the data,
  /// not asserted by the save site.
  Future<int?> save(Hold hold) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    return _db.transaction(() async {
      await _db
          .into(_db.holds)
          .insertOnConflictUpdate(
            db.HoldsCompanion(
              id: Value(hold.id),
              createdAt: Value(hold.createdAt.millisecondsSinceEpoch),
              updatedAt: Value(now),
              deviceId: Value(_deviceId),
              durationMs: Value(hold.duration.inMilliseconds),
              contractionMs: Value(hold.contractionTime?.inMilliseconds),
              type: Value(hold.type.dbValue),
              lungVolume: Value(hold.lungVolume.dbValue),
              prepMode: Value(hold.prepMode?.dbValue),
              notes: Value(hold.notes),
              isPb: Value(hold.isPb ? 1 : 0),
              rating: Value(hold.rating),
              deleted: const Value(0),
            ),
          );
      // Table rounds save as co2/o2 holds, eight at a time. They can never
      // change the PB, so don't pay for a recompute on each one.
      if (hold.type != HoldType.max) return null;
      return recomputePbFlags();
    });
  }

  /// Clears `is_pb` across every max hold and sets it on the single longest
  /// non-deleted one, returning that hold's duration in ms (null when no max
  /// holds remain).
  ///
  /// `is_pb` is stored rather than derived at read time — the progress
  /// providers read the column directly — so every write path that can change
  /// which hold is longest has to call this: save, delete, and merge. Before
  /// the save path did, the previous record holder kept its flag and the
  /// history list showed a PB badge on two different holds.
  ///
  /// Deliberately does not stamp `updatedAt`: the flag is derived state each
  /// device regenerates independently, not an edit worth syncing.
  Future<int?> recomputePbFlags() async {
    await (_db.update(_db.holds)..where((t) => t.type.equals('max'))).write(
      const db.HoldsCompanion(isPb: Value(0)),
    );
    final best =
        await (_db.select(_db.holds)
              ..where((t) => t.type.equals('max') & t.deleted.equals(0))
              ..orderBy([
                (t) => OrderingTerm.desc(t.durationMs),
                (t) => OrderingTerm.asc(t.createdAt),
                (t) => OrderingTerm.asc(t.id),
              ])
              ..limit(1))
            .getSingleOrNull();
    if (best == null) return null;
    await (_db.update(_db.holds)..where((t) => t.id.equals(best.id))).write(
      const db.HoldsCompanion(isPb: Value(1)),
    );
    return best.durationMs;
  }

  Future<List<Hold>> getAll() async {
    final rows =
        await (_db.select(_db.holds)
              ..where((t) => t.deleted.equals(0))
              ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
            .get();
    return rows.map(_fromRow).toList();
  }

  Future<Hold?> getById(String id) async {
    final row = await (_db.select(
      _db.holds,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return row == null ? null : _fromRow(row);
  }

  Future<void> saveHoldTags(String holdId, List<String> tagIds) async {
    for (final tagId in tagIds) {
      await _db
          .into(_db.holdTags)
          .insertOnConflictUpdate(
            db.HoldTagsCompanion.insert(holdId: holdId, tagId: tagId),
          );
    }
  }

  /// Replaces a hold's tag associations entirely, dropping any not in
  /// [tagIds]. Used by the hold detail edit form.
  Future<void> replaceHoldTags(String holdId, List<String> tagIds) async {
    await (_db.delete(
      _db.holdTags,
    )..where((t) => t.holdId.equals(holdId))).go();
    await saveHoldTags(holdId, tagIds);
  }

  /// Updates a hold's lung volume in place. Used by the hold detail edit
  /// form; duration and timestamps are never editable.
  Future<void> updateLungVolume(String id, LungVolume lungVolume) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (_db.update(_db.holds)..where((t) => t.id.equals(id))).write(
      db.HoldsCompanion(
        lungVolume: Value(lungVolume.dbValue),
        updatedAt: Value(now),
      ),
    );
  }

  /// Bulk upsert for sync: writes each record's `updatedAt`/`deviceId` as
  /// given, rather than stamping local values the way [save] does, and
  /// replaces each hold's tag set wholesale to match [SyncHoldRecord.tagIds].
  Future<void> upsertAll(List<SyncHoldRecord> records) async {
    if (records.isEmpty) return;
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.holds, [
        for (final r in records)
          db.HoldsCompanion(
            id: Value(r.id),
            createdAt: Value(r.createdAt),
            updatedAt: Value(r.updatedAt),
            deviceId: Value(r.deviceId),
            durationMs: Value(r.durationMs),
            contractionMs: Value(r.contractionMs),
            type: Value(r.type),
            lungVolume: Value(r.lungVolume),
            prepMode: Value(r.prepMode),
            notes: Value(r.notes),
            isPb: Value(r.isPb ? 1 : 0),
            rating: Value(r.rating),
            deleted: Value(r.deleted ? 1 : 0),
          ),
      ]);
    });

    final ids = records.map((r) => r.id).toList();
    await (_db.delete(_db.holdTags)..where((t) => t.holdId.isIn(ids))).go();
    await _db.batch((batch) {
      batch.insertAll(_db.holdTags, [
        for (final r in records)
          for (final tagId in r.tagIds)
            db.HoldTagsCompanion.insert(holdId: r.id, tagId: tagId),
      ]);
    });
  }

  /// Soft-deletes a hold and, when it was a max hold, moves the PB flag to
  /// whatever is now longest. Returns the new best max-hold duration in ms.
  Future<int?> delete(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    return _db.transaction(() async {
      final row = await (_db.select(
        _db.holds,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
      await (_db.update(_db.holds)..where((t) => t.id.equals(id))).write(
        db.HoldsCompanion(deleted: const Value(1), updatedAt: Value(now)),
      );
      if (row == null || row.type != 'max') return null;
      return recomputePbFlags();
    });
  }

  Hold _fromRow(db.Hold row) {
    return Hold(
      id: row.id,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(row.updatedAt),
      deviceId: row.deviceId,
      duration: Duration(milliseconds: row.durationMs),
      contractionTime: row.contractionMs == null
          ? null
          : Duration(milliseconds: row.contractionMs!),
      type: HoldType.fromDb(row.type),
      lungVolume: LungVolume.fromDb(row.lungVolume),
      prepMode: PrepMode.fromDb(row.prepMode),
      notes: row.notes,
      isPb: row.isPb == 1,
      rating: row.rating,
    );
  }
}

final holdsRepositoryProvider = FutureProvider<HoldsRepository>((ref) async {
  final database = ref.watch(databaseProvider);
  final deviceId = await ref.watch(deviceIdProvider.future);
  return HoldsRepository(database, deviceId);
});

/// All non-deleted holds, newest first.
final allHoldsProvider = FutureProvider<List<Hold>>((ref) async {
  final repo = await ref.watch(holdsRepositoryProvider.future);
  return repo.getAll();
});

/// Maps holdId → tag count for all holds. Fetched once; invalidate after save.
final holdTagCountsProvider = FutureProvider<Map<String, int>>((ref) async {
  final database = ref.watch(databaseProvider);
  final rows = await database.select(database.holdTags).get();
  final counts = <String, int>{};
  for (final row in rows) {
    counts[row.holdId] = (counts[row.holdId] ?? 0) + 1;
  }
  return counts;
});

/// Maps holdId → set of tagIds for all holds. Used by the history tag
/// filter. Fetched once; invalidate after save.
final holdTagIdsProvider = FutureProvider<Map<String, Set<String>>>((
  ref,
) async {
  final database = ref.watch(databaseProvider);
  final rows = await database.select(database.holdTags).get();
  final tagIds = <String, Set<String>>{};
  for (final row in rows) {
    (tagIds[row.holdId] ??= {}).add(row.tagId);
  }
  return tagIds;
});
