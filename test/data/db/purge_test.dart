import 'package:breath_lab/data/db/app_database.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  int daysAgo(int days) =>
      DateTime.now().subtract(Duration(days: days)).millisecondsSinceEpoch;

  Future<void> insertHold(
    String id, {
    required int deleted,
    required int updatedAt,
  }) {
    return db
        .into(db.holds)
        .insert(
          HoldsCompanion.insert(
            id: id,
            createdAt: updatedAt,
            updatedAt: updatedAt,
            deviceId: 'dev',
            durationMs: 1000,
            type: 'max',
            lungVolume: 'full',
            deleted: Value(deleted),
          ),
        );
  }

  test(
    'purges tombstones past the retention window, keeps everything else',
    () async {
      await insertHold('old-tombstone', deleted: 1, updatedAt: daysAgo(200));
      await insertHold('recent-tombstone', deleted: 1, updatedAt: daysAgo(10));
      await insertHold('live', deleted: 0, updatedAt: daysAgo(200));
      await db
          .into(db.holdTags)
          .insert(
            const HoldTagsCompanion(
              holdId: Value('old-tombstone'),
              tagId: Value('t1'),
            ),
          );

      await db.purgeOldTombstones(retention: const Duration(days: 180));

      final remaining = await db.select(db.holds).get();
      expect(
        remaining.map((h) => h.id),
        unorderedEquals(['recent-tombstone', 'live']),
      );

      final orphanedTags = await db.select(db.holdTags).get();
      expect(orphanedTags, isEmpty);
    },
  );

  test('purges table sessions and IMST sessions the same way', () async {
    await db
        .into(db.tableSessions)
        .insert(
          TableSessionsCompanion.insert(
            id: 'old-table',
            createdAt: daysAgo(200),
            updatedAt: daysAgo(200),
            deviceId: 'dev',
            type: 'co2',
            basedOnMaxMs: 1000,
            roundsTotal: 8,
            roundsCompleted: 8,
            roundDetails: '[]',
            deleted: const Value(1),
          ),
        );
    await db
        .into(db.imstSessions)
        .insert(
          ImstSessionsCompanion.insert(
            id: 'old-imst',
            createdAt: daysAgo(200),
            updatedAt: daysAgo(200),
            deviceId: 'dev',
            breaths: 30,
            deleted: const Value(1),
          ),
        );

    await db.purgeOldTombstones(retention: const Duration(days: 180));

    expect(await db.select(db.tableSessions).get(), isEmpty);
    expect(await db.select(db.imstSessions).get(), isEmpty);
  });
}
