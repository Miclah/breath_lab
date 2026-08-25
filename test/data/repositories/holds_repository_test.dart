import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:breath_lab/data/db/app_database.dart' hide Hold;
import 'package:breath_lab/data/repositories/holds_repository.dart';
import 'package:breath_lab/domain/models/hold.dart';
import 'package:breath_lab/domain/models/sync_payload.dart';

Hold _hold(
  String id, {
  required int seconds,
  HoldType type = HoldType.max,
  bool isPb = false,
  int createdAtMs = 1000,
}) {
  return Hold(
    id: id,
    createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMs),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(createdAtMs),
    deviceId: 'local-device',
    duration: Duration(seconds: seconds),
    type: type,
    lungVolume: LungVolume.full,
    isPb: isPb,
  );
}

SyncHoldRecord _record(String id, {required int seconds, bool isPb = false}) {
  return SyncHoldRecord(
    id: id,
    createdAt: 1000,
    updatedAt: 1000,
    deviceId: 'peer-device',
    durationMs: seconds * 1000,
    type: 'max',
    lungVolume: 'full',
    isPb: isPb,
    deleted: false,
    tagIds: const [],
  );
}

void main() {
  group('PB flag exclusivity', () {
    late AppDatabase db;
    late HoldsRepository repo;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = HoldsRepository(db, 'local-device');
    });

    tearDown(() => db.close());

    /// Ids of every hold currently carrying the flag — the whole point is
    /// that this is never longer than one element.
    Future<List<String>> pbIds() async {
      final rows = await db.select(db.holds).get();
      return [
        for (final r in rows)
          if (r.isPb == 1) r.id,
      ];
    }

    test('the first max hold carries the flag', () async {
      await repo.save(_hold('a', seconds: 60));
      expect(await pbIds(), ['a']);
    });

    test('a longer hold takes the flag off the previous holder', () async {
      await repo.save(_hold('a', seconds: 60));
      final best = await repo.save(_hold('b', seconds: 90));

      expect(await pbIds(), ['b']);
      expect(best, 90000);
    });

    test('a shorter hold does not take the flag', () async {
      await repo.save(_hold('a', seconds: 90));
      await repo.save(_hold('b', seconds: 60));
      expect(await pbIds(), ['a']);
    });

    test('the caller cannot assert its way to a PB it did not earn', () async {
      await repo.save(_hold('a', seconds: 90));
      // The save site used to be believed. It no longer is.
      await repo.save(_hold('b', seconds: 30, isPb: true));
      expect(await pbIds(), ['a']);
    });

    test('tied durations still yield exactly one holder', () async {
      await repo.save(_hold('a', seconds: 60, createdAtMs: 2000));
      await repo.save(_hold('b', seconds: 60, createdAtMs: 1000));
      // Earliest createdAt wins, so the result does not depend on the order
      // the rows happen to come back in.
      expect(await pbIds(), ['b']);
    });

    test('table rounds neither take nor disturb the flag', () async {
      await repo.save(_hold('a', seconds: 60));
      await repo.save(_hold('c1', seconds: 120, type: HoldType.co2));
      await repo.save(_hold('o1', seconds: 180, type: HoldType.o2));

      expect(await pbIds(), ['a']);
    });

    test(
      'deleting the record holder moves the flag to the next longest',
      () async {
        await repo.save(_hold('a', seconds: 60));
        await repo.save(_hold('b', seconds: 90));

        final best = await repo.delete('b');

        expect(await pbIds(), ['a']);
        expect(best, 60000);
      },
    );

    test('deleting the only max hold leaves nobody holding it', () async {
      await repo.save(_hold('a', seconds: 60));

      final best = await repo.delete('a');

      expect(await pbIds(), isEmpty);
      expect(best, isNull);
    });

    test('deleting a table round does not disturb the flag', () async {
      await repo.save(_hold('a', seconds: 60));
      await repo.save(_hold('c1', seconds: 120, type: HoldType.co2));

      final best = await repo.delete('c1');

      expect(await pbIds(), ['a']);
      expect(best, isNull);
    });

    test('an import that brings in a longer hold moves the flag', () async {
      await repo.save(_hold('a', seconds: 60));
      // What the merge path does: bulk upsert, then re-derive.
      await repo.upsertAll([_record('peer', seconds: 120)]);
      final best = await repo.recomputePbFlags();

      expect(await pbIds(), ['peer']);
      expect(best, 120000);
    });

    test(
      'an import carrying its own stale flag does not create a second',
      () async {
        await repo.save(_hold('a', seconds: 120));
        // The peer thought its 60s hold was the PB, because on that device it
        // was. Two devices' flags cannot both survive the merge.
        await repo.upsertAll([_record('peer', seconds: 60, isPb: true)]);
        await repo.recomputePbFlags();

        expect(await pbIds(), ['a']);
      },
    );

    test('a soft-deleted hold cannot hold the flag', () async {
      await repo.save(_hold('a', seconds: 60));
      await repo.save(_hold('b', seconds: 90));
      await (db.update(db.holds)..where((t) => t.id.equals('b'))).write(
        const HoldsCompanion(deleted: Value(1)),
      );

      final best = await repo.recomputePbFlags();

      expect(await pbIds(), ['a']);
      expect(best, 60000);
    });
  });
}
