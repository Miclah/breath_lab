import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../db/app_database.dart' as db;
import '../db/database_provider.dart';
import '../../domain/models/sync_payload.dart';

class TagsRepository {
  TagsRepository(this._db);

  final db.AppDatabase _db;
  static const _uuid = Uuid();

  /// Bulk upsert for sync: writes each record's `updatedAt` as given,
  /// rather than stamping the local clock the way [insertCustom] does.
  Future<void> upsertAll(List<SyncTagRecord> records) async {
    if (records.isEmpty) return;
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.tags, [
        for (final r in records)
          db.TagsCompanion(
            id: Value(r.id),
            labelKey: Value(r.labelKey),
            createdAt: Value(r.createdAt),
            updatedAt: Value(r.updatedAt),
            deleted: Value(r.deleted ? 1 : 0),
          ),
      ]);
    });
  }

  Future<List<db.Tag>> getAllActive() {
    return (_db.select(_db.tags)
          ..where((t) => t.deleted.equals(0))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  /// Inserts a custom tag row and returns it. Called during hold save.
  Future<db.Tag> insertCustom(String text) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = _uuid.v4();
    await _db
        .into(_db.tags)
        .insert(
          db.TagsCompanion.insert(
            id: id,
            labelKey: 'custom:$text',
            createdAt: now,
            updatedAt: now,
          ),
        );
    return (_db.select(_db.tags)..where((t) => t.id.equals(id))).getSingle();
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final tagsRepositoryProvider = Provider<TagsRepository>((ref) {
  return TagsRepository(ref.watch(databaseProvider));
});

/// All non-deleted tags ordered by creation time.
final builtInTagsProvider = FutureProvider<List<db.Tag>>((ref) {
  return ref.watch(tagsRepositoryProvider).getAllActive();
});

/// Tags linked to a specific hold, loaded on demand (e.g. detail sheet).
final holdTagsProvider = FutureProvider.family<List<db.Tag>, String>((
  ref,
  holdId,
) async {
  final database = ref.watch(databaseProvider);
  final tagIdRows = await (database.select(
    database.holdTags,
  )..where((t) => t.holdId.equals(holdId))).get();
  final ids = tagIdRows.map((r) => r.tagId).toList();
  if (ids.isEmpty) return [];
  return (database.select(database.tags)..where((t) => t.id.isIn(ids))).get();
});
