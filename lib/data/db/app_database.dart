import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:uuid/uuid.dart';

part 'app_database.g.dart';

// ---------------------------------------------------------------------------
// Tables
// ---------------------------------------------------------------------------

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

@DriftDatabase(tables: [Holds, Tags, HoldTags, Settings, TableSessions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

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
    },
  );

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
