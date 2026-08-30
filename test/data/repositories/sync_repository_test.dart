import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:breath_lab/data/db/app_database.dart' hide Hold, ImstSession;
import 'package:breath_lab/data/repositories/holds_repository.dart';
import 'package:breath_lab/data/repositories/imst_sessions_repository.dart';
import 'package:breath_lab/data/repositories/settings_repository.dart';
import 'package:breath_lab/data/repositories/sync_repository.dart';
import 'package:breath_lab/data/repositories/table_sessions_repository.dart';
import 'package:breath_lab/data/repositories/tags_repository.dart';
import 'package:breath_lab/domain/models/hold.dart';
import 'package:breath_lab/domain/models/imst_session.dart';
import 'package:breath_lab/domain/models/sync_payload.dart';
import 'package:breath_lab/domain/services/sync_merge_service.dart';

void main() {
  group('SyncRepository', () {
    late AppDatabase db;
    late HoldsRepository holdsRepo;
    late ImstSessionsRepository imstRepo;
    late SyncRepository syncRepo;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      holdsRepo = HoldsRepository(db, 'local-device');
      imstRepo = ImstSessionsRepository(db, 'local-device');
      syncRepo = SyncRepository(
        database: db,
        deviceId: 'local-device',
        holdsRepo: holdsRepo,
        sessionsRepo: TableSessionsRepository(db, 'local-device'),
        imstRepo: imstRepo,
        tagsRepo: TagsRepository(db),
        settingsRepo: SettingsRepository(db),
      );
    });

    tearDown(() => db.close());

    test(
      'buildLocalPayload reflects seeded holds, including their tag set',
      () async {
        await holdsRepo.save(
          Hold(
            id: 'h1',
            createdAt: DateTime.fromMillisecondsSinceEpoch(1000),
            updatedAt: DateTime.fromMillisecondsSinceEpoch(1000),
            deviceId: 'local-device',
            duration: const Duration(seconds: 90),
            type: HoldType.max,
            lungVolume: LungVolume.full,
            isPb: true,
          ),
        );
        final builtInTag = (await db.select(db.tags).get()).first;
        await holdsRepo.saveHoldTags('h1', [builtInTag.id]);

        final payload = await syncRepo.buildLocalPayload(appVersion: '1.0.0');

        expect(payload.schemaVersion, db.schemaVersion);
        expect(payload.deviceId, 'local-device');
        final hold = payload.holds.singleWhere((h) => h.id == 'h1');
        expect(hold.durationMs, 90000);
        expect(hold.tagIds, [builtInTag.id]);
        // Built-in tags are seeded on first open — the payload must carry
        // them too, or a fresh install synced elsewhere would lose them.
        expect(payload.tags.map((t) => t.id), contains(builtInTag.id));
      },
    );

    test(
      'applyMerge writes a brand-new hold and its brand-new tag without '
      'tripping the hold_tags foreign key, and recomputes the PB flag',
      () async {
        // A pre-existing local max hold that currently holds the PB.
        await holdsRepo.save(
          Hold(
            id: 'local-pb',
            createdAt: DateTime.fromMillisecondsSinceEpoch(1000),
            updatedAt: DateTime.fromMillisecondsSinceEpoch(1000),
            deviceId: 'local-device',
            duration: const Duration(seconds: 60),
            type: HoldType.max,
            lungVolume: LungVolume.full,
            isPb: true,
          ),
        );
        await db
            .into(db.settings)
            .insert(
              SettingsCompanion.insert(
                key: 'current_max_ms',
                value: '60000',
                updatedAt: 2000,
              ),
            );

        final local = await syncRepo.buildLocalPayload(appVersion: '1.0.0');
        // The remote brings a longer hold tagged with a tag it also brings
        // — one this device has never seen — plus all of local's own tags
        // (a real remote payload always carries its own copy of everything
        // it knows about, built-ins included).
        final remote = SyncPayload(
          schemaVersion: db.schemaVersion,
          exportedAt: 5000,
          deviceId: 'remote-device',
          deviceName: "Remote's Phone",
          appVersion: '1.0.0',
          holds: [
            SyncHoldRecord(
              id: 'remote-longer',
              createdAt: 3000,
              updatedAt: 3000,
              deviceId: 'remote-device',
              durationMs: 120000,
              type: 'max',
              lungVolume: 'full',
              isPb: false,
              deleted: false,
              tagIds: const ['brand-new-tag'],
            ),
          ],
          tableSessions: const [],
          tags: [
            ...local.tags,
            const SyncTagRecord(
              id: 'brand-new-tag',
              labelKey: 'custom:new',
              createdAt: 3000,
              updatedAt: 3000,
              deleted: false,
            ),
          ],
        );

        final result = SyncMergeService.merge(local: local, remote: remote);
        await syncRepo.applyMerge(
          result: result,
          peerDeviceName: remote.deviceName,
        );

        final holdRows = await db.select(db.holds).get();
        final byId = {for (final row in holdRows) row.id: row};
        expect(byId['local-pb']!.isPb, 0);
        expect(byId['remote-longer']!.isPb, 1);

        final holdTagRows = await (db.select(
          db.holdTags,
        )..where((t) => t.holdId.equals('remote-longer'))).get();
        expect(holdTagRows.single.tagId, 'brand-new-tag');

        final maxMs = await SettingsRepository(db).getCurrentMaxMs();
        expect(maxMs, 120000);
      },
    );

    test('applyMerge stamps last_sync_at and the peer device name', () async {
      final local = await syncRepo.buildLocalPayload(appVersion: '1.0.0');
      final remote = SyncPayload(
        schemaVersion: db.schemaVersion,
        exportedAt: 5000,
        deviceId: 'remote-device',
        deviceName: "Remote's Phone",
        appVersion: '1.0.0',
        holds: const [],
        tableSessions: const [],
        tags: local.tags,
      );

      final result = SyncMergeService.merge(local: local, remote: remote);
      await syncRepo.applyMerge(
        result: result,
        peerDeviceName: remote.deviceName,
      );

      final settingsRepo = SettingsRepository(db);
      expect(await settingsRepo.getLastSyncAtMs(), isNotNull);
      expect(await settingsRepo.getLastSyncPeerName(), "Remote's Phone");
    });

    test(
      'an IMST session survives an encode/decode export round trip',
      () async {
        await imstRepo.save(
          ImstSession(
            id: 'imst-1',
            createdAt: DateTime.fromMillisecondsSinceEpoch(1000),
            updatedAt: DateTime.fromMillisecondsSinceEpoch(1000),
            deviceId: 'local-device',
            breaths: 30,
            deviceName: 'POWERbreathe Plus',
            deviceLevel: 4,
            duration: const Duration(minutes: 2),
          ),
        );

        final payload = await syncRepo.buildLocalPayload(appVersion: '1.0.0');
        final restored = SyncPayload.decode(payload.encode());

        expect(payload.schemaVersion, db.schemaVersion);
        final session = restored.imstSessions.singleWhere(
          (s) => s.id == 'imst-1',
        );
        expect(session.breaths, 30);
        expect(session.deviceName, 'POWERbreathe Plus');
        expect(session.deviceLevel, 4);
        expect(session.durationMs, 120000);
      },
    );

    test('applyMerge writes an incoming IMST session to the table', () async {
      final local = await syncRepo.buildLocalPayload(appVersion: '1.0.0');
      final remote = SyncPayload(
        schemaVersion: db.schemaVersion,
        exportedAt: 5000,
        deviceId: 'remote-device',
        deviceName: "Remote's Phone",
        appVersion: '1.0.0',
        holds: const [],
        tableSessions: const [],
        imstSessions: const [
          SyncImstSessionRecord(
            id: 'remote-imst',
            createdAt: 3000,
            updatedAt: 3000,
            deviceId: 'remote-device',
            breaths: 28,
            deviceLevel: 6,
            deleted: false,
          ),
        ],
        tags: local.tags,
      );

      final result = SyncMergeService.merge(local: local, remote: remote);
      await syncRepo.applyMerge(
        result: result,
        peerDeviceName: remote.deviceName,
      );

      final rows = await db.select(db.imstSessions).get();
      expect(rows.single.id, 'remote-imst');
      expect(rows.single.breaths, 28);
      expect(rows.single.deviceLevel, 6);
    });
  });
}
