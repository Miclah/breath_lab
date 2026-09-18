import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

part 'app_database.g.dart';

// ---------------------------------------------------------------------------
// Tables
// ---------------------------------------------------------------------------

// Every read filters on `deleted` at minimum, and the hot paths (recomputing
// the PB flag on every max-hold save, listing history) also filter on `type`
// or order by `createdAt` — all unindexed until now, so every one of those
// queries full-scans the table. Fine at the row counts this app started
// with; not fine after a few years of daily use.
@TableIndex(
  name: 'idx_holds_type_deleted_duration',
  columns: {#type, #deleted, #durationMs},
)
@TableIndex(name: 'idx_holds_deleted_created', columns: {#deleted, #createdAt})
class Holds extends Table {
  TextColumn get id => text()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  TextColumn get deviceId => text()();
  IntColumn get durationMs => integer()();
  IntColumn get contractionMs => integer().nullable()();
  // 'max' | 'co2' | 'o2' | 'walk'
  TextColumn get type => text()();
  // 'full' | 'frc' | 'empty'
  TextColumn get lungVolume => text()();
  // 'none' | '3s' | 'short' | 'full'
  TextColumn get prepMode => text().nullable()();
  TextColumn get notes => text().nullable()();
  IntColumn get isPb => integer().withDefault(const Constant(0))();
  IntColumn get rating => integer().nullable()();
  IntColumn get deleted => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class Tags extends Table {
  TextColumn get id => text()();
  // localization key, e.g. 'tag.tired'; custom tags use 'custom:<text>'
  TextColumn get labelKey => text()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deleted => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class HoldTags extends Table {
  TextColumn get holdId => text().references(Holds, #id)();
  TextColumn get tagId => text().references(Tags, #id)();

  @override
  Set<Column> get primaryKey => {holdId, tagId};
}

class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {key};
}

@TableIndex(
  name: 'idx_table_sessions_deleted_created',
  columns: {#deleted, #createdAt},
)
class TableSessions extends Table {
  TextColumn get id => text()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  TextColumn get deviceId => text()();
  // 'co2' | 'o2'
  TextColumn get type => text()();
  IntColumn get basedOnMaxMs => integer()();
  IntColumn get roundsTotal => integer()();
  IntColumn get roundsCompleted => integer()();
  // JSON-encoded list of per-round hold/rest results
  TextColumn get roundDetails => text()();
  IntColumn get deleted => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(
  name: 'idx_imst_sessions_deleted_created',
  columns: {#deleted, #createdAt},
)
class ImstSessions extends Table {
  TextColumn get id => text()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  TextColumn get deviceId => text()();
  IntColumn get breaths => integer()();
  // Free-text trainer name; the numbered resistance position the user set.
  TextColumn get deviceName => text().nullable()();
  IntColumn get deviceLevel => integer().nullable()();
  // Measured maximal inspiratory pressure and session load, for the minority
  // who have a real figure. Never inferred from the dial.
  IntColumn get pimaxCmh2o => integer().nullable()();
  IntColumn get percentPimax => integer().nullable()();
  IntColumn get durationMs => integer().nullable()();
  IntColumn get deleted => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Database
// ---------------------------------------------------------------------------

const _builtInTagKeys = [
  'tag.tired',
  'tag.wellRested',
  'tag.fullStomach',
  'tag.emptyStomach',
  'tag.anxious',
  'tag.greatPrep',
  'tag.samba',
  'tag.cold',
  'tag.hot',
];

@DriftDatabase(
  tables: [Holds, Tags, HoldTags, Settings, TableSessions, ImstSessions],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// For widget/unit tests — pass an in-memory [QueryExecutor] (e.g.
  /// `NativeDatabase.memory()`) instead of the real on-disk database.
  @visibleForTesting
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedBuiltInTags();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(tableSessions);
      }
      if (from < 3) {
        await m.createTable(imstSessions);
      }
      if (from < 4) {
        await m.createIndex(idxHoldsTypeDeletedDuration);
        await m.createIndex(idxHoldsDeletedCreated);
        await m.createIndex(idxTableSessionsDeletedCreated);
        await m.createIndex(idxImstSessionsDeletedCreated);
      }
    },
  );

  /// Wipes all locally stored data (holds, tags, table sessions, settings)
  /// and re-seeds the built-in tags, as if the app were freshly installed.
  Future<void> resetAllData() async {
    await transaction(() async {
      await delete(holdTags).go();
      await delete(holds).go();
      await delete(imstSessions).go();
      await delete(tableSessions).go();
      await delete(tags).go();
      await delete(settings).go();
      await _seedBuiltInTags();
    });
  }

  /// Permanently removes soft-deleted rows older than [retention].
  ///
  /// Tombstones (`deleted = 1`) are kept rather than hard-deleted so a sync
  /// partner that hasn't connected in a while still learns the row is gone
  /// instead of resurrecting it. Kept forever, though, they're a monotonic
  /// leak: `.blab` export size and sync payload size only ever grow. Six
  /// months is long enough for any of the user's own devices — the only
  /// sync partners this app has — to have reconnected at least once.
  Future<void> purgeOldTombstones({
    Duration retention = const Duration(days: 180),
  }) async {
    final cutoff = DateTime.now().subtract(retention).millisecondsSinceEpoch;
    await transaction(() async {
      final staleHoldIds =
          await (select(holds)..where(
                (t) =>
                    t.deleted.equals(1) &
                    t.updatedAt.isSmallerThanValue(cutoff),
              ))
              .map((row) => row.id)
              .get();
      if (staleHoldIds.isNotEmpty) {
        await (delete(
          holdTags,
        )..where((t) => t.holdId.isIn(staleHoldIds))).go();
        await (delete(holds)..where((t) => t.id.isIn(staleHoldIds))).go();
      }
      await (delete(tableSessions)..where(
            (t) => t.deleted.equals(1) & t.updatedAt.isSmallerThanValue(cutoff),
          ))
          .go();
      await (delete(imstSessions)..where(
            (t) => t.deleted.equals(1) & t.updatedAt.isSmallerThanValue(cutoff),
          ))
          .go();
    });
  }

  Future<void> _seedBuiltInTags() async {
    const uuid = Uuid();
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final key in _builtInTagKeys) {
      await into(tags).insert(
        TagsCompanion.insert(
          id: uuid.v4(),
          labelKey: key,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'breath_lab');
}
