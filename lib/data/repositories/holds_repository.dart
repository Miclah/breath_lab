import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../db/app_database.dart' as db;
import '../db/database_provider.dart';
import '../../domain/models/hold.dart';
import 'device_id_provider.dart';

class HoldsRepository {
  HoldsRepository(this._db, this._deviceId);

  final db.AppDatabase _db;
  final String _deviceId;
  static const _uuid = Uuid();

  String newId() => _uuid.v4();

  Future<void> save(Hold hold) async {
    final now = DateTime.now().millisecondsSinceEpoch;
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

  Future<void> delete(String id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (_db.update(_db.holds)..where((t) => t.id.equals(id))).write(
      db.HoldsCompanion(deleted: const Value(1), updatedAt: Value(now)),
    );
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
