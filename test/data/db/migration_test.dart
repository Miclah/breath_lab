import 'dart:io';

import 'package:breath_lab/data/db/app_database.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every migration so far is additive (a new table or index). To stand in for
/// "a database written by an older build" we realise the current schema, drop
/// what a later version added, and roll `user_version` back. Reopening then
/// drives `onUpgrade` from that point.
void main() {
  late Directory dir;
  late File file;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('breath_lab_mig');
    file = File('${dir.path}/db.sqlite');
  });

  tearDown(() => dir.deleteSync(recursive: true));

  Future<void> insertHold(AppDatabase db, String id, int durationMs) {
    return db
        .into(db.holds)
        .insert(
          HoldsCompanion.insert(
            id: id,
            createdAt: 1000,
            updatedAt: 1000,
            deviceId: 'dev',
            durationMs: durationMs,
            type: 'max',
            lungVolume: 'full',
          ),
        );
  }

  test('a pre-v3 database migrates, keeping every existing hold', () async {
    var db = AppDatabase.forTesting(NativeDatabase(file));
    await insertHold(db, 'h1', 90000);
    await insertHold(db, 'h2', 120000);
    // Dropping the table takes its index with it; the other two need
    // dropping explicitly.
    await db.customStatement('DROP TABLE imst_sessions');
    await db.customStatement('DROP INDEX idx_holds_type_deleted_duration');
    await db.customStatement('DROP INDEX idx_holds_deleted_created');
    await db.customStatement('DROP INDEX idx_table_sessions_deleted_created');
    await db.customStatement('PRAGMA user_version = 2');
    await db.close();

    db = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(db.close);

    final holds = await db.select(db.holds).get();
    expect(holds.map((h) => h.id), unorderedEquals(['h1', 'h2']));
    expect(holds.firstWhere((h) => h.id == 'h1').durationMs, 90000);

    // The migration recreated the table and it is usable.
    final imst = await db.select(db.imstSessions).get();
    expect(imst, isEmpty);

    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.single, db.schemaVersion);
  });

  test('a pre-v4 database migrates, adding the new indices', () async {
    var db = AppDatabase.forTesting(NativeDatabase(file));
    await insertHold(db, 'h1', 90000);
    await db.customStatement('DROP INDEX idx_holds_type_deleted_duration');
    await db.customStatement('DROP INDEX idx_holds_deleted_created');
    await db.customStatement('DROP INDEX idx_table_sessions_deleted_created');
    await db.customStatement('DROP INDEX idx_imst_sessions_deleted_created');
    await db.customStatement('PRAGMA user_version = 3');
    await db.close();

    db = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(db.close);

    final holds = await db.select(db.holds).get();
    expect(holds.map((h) => h.id), ['h1']);

    final indexNames = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'index' AND name LIKE 'idx_%'",
        )
        .get();
    expect(
      indexNames.map((r) => r.data['name']),
      containsAll([
        'idx_holds_type_deleted_duration',
        'idx_holds_deleted_created',
        'idx_table_sessions_deleted_created',
        'idx_imst_sessions_deleted_created',
      ]),
    );

    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.single, db.schemaVersion);
  });

  test('a pre-v2 database migrates straight to current in one jump', () async {
    // Stands in for a user who skips several releases in one update, rather
    // than upgrading one version at a time.
    var db = AppDatabase.forTesting(NativeDatabase(file));
    await insertHold(db, 'h1', 90000);
    await db.customStatement('DROP INDEX idx_holds_type_deleted_duration');
    await db.customStatement('DROP INDEX idx_holds_deleted_created');
    await db.customStatement('DROP INDEX idx_table_sessions_deleted_created');
    await db.customStatement('DROP INDEX idx_imst_sessions_deleted_created');
    await db.customStatement('DROP TABLE imst_sessions');
    await db.customStatement('DROP TABLE table_sessions');
    await db.customStatement('PRAGMA user_version = 1');
    await db.close();

    db = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(db.close);

    final holds = await db.select(db.holds).get();
    expect(holds.map((h) => h.id), ['h1']);
    expect(await db.select(db.tableSessions).get(), isEmpty);
    expect(await db.select(db.imstSessions).get(), isEmpty);

    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.single, db.schemaVersion);
  });

  test('a fresh database accepts imst, stretch and rest rows', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await db
        .into(db.imstSessions)
        .insert(
          ImstSessionsCompanion.insert(
            id: 's1',
            createdAt: 1,
            updatedAt: 1,
            deviceId: 'dev',
            breaths: 30,
            deviceName: const Value('POWERbreathe'),
            deviceLevel: const Value(4),
          ),
        );
    for (final type in ['stretch', 'rest']) {
      await db
          .into(db.holds)
          .insert(
            HoldsCompanion.insert(
              id: type,
              createdAt: 1,
              updatedAt: 1,
              deviceId: 'dev',
              durationMs: 0,
              type: type,
              lungVolume: 'full',
            ),
          );
    }

    expect(await db.select(db.imstSessions).get(), hasLength(1));
    expect(await db.select(db.holds).get(), hasLength(2));
  });
}
