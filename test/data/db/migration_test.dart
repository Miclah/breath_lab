import 'dart:io';

import 'package:breath_lab/data/db/app_database.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// The v3 migration is additive — it only creates `imst_sessions`. To stand in
/// for "a database written by a build that predates v3" we realise the current
/// schema, drop the new table, and roll `user_version` back to 2. Reopening
/// then drives `onUpgrade(_, 2, 3)`.
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
    await db.customStatement('DROP TABLE imst_sessions');
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
