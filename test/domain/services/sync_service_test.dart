import 'package:breath_lab/data/db/app_database.dart' hide Hold;
import 'package:breath_lab/data/repositories/holds_repository.dart';
import 'package:breath_lab/data/repositories/imst_sessions_repository.dart';
import 'package:breath_lab/data/repositories/settings_repository.dart';
import 'package:breath_lab/data/repositories/sync_repository.dart';
import 'package:breath_lab/data/repositories/table_sessions_repository.dart';
import 'package:breath_lab/data/repositories/tags_repository.dart';
import 'package:breath_lab/domain/models/hold.dart';
import 'package:breath_lab/domain/models/sync_payload.dart';
import 'package:breath_lab/domain/services/sync_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late SyncService service;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    final syncRepo = SyncRepository(
      database: db,
      deviceId: 'local-device',
      holdsRepo: HoldsRepository(db, 'local-device'),
      sessionsRepo: TableSessionsRepository(db, 'local-device'),
      imstRepo: ImstSessionsRepository(db, 'local-device'),
      tagsRepo: TagsRepository(db),
      settingsRepo: SettingsRepository(db),
    );
    service = SyncService(
      syncRepo: syncRepo,
      database: db,
      appVersion: '1.0.0',
    );
  });

  tearDown(() => db.close());

  Future<void> seedLocalHold(String id, int at) =>
      HoldsRepository(db, 'local-device').save(
        Hold(
          id: id,
          createdAt: DateTime.fromMillisecondsSinceEpoch(at),
          updatedAt: DateTime.fromMillisecondsSinceEpoch(at),
          deviceId: 'local-device',
          duration: const Duration(seconds: 90),
          type: HoldType.max,
          lungVolume: LungVolume.full,
          isPb: false,
        ),
      );

  test(
    'applyRemotePayload merges a remote hold and reports the count',
    () async {
      await seedLocalHold('h-local', 1000);

      // A payload as if it came from another device.
      final remoteDb = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(remoteDb.close);
      await HoldsRepository(remoteDb, 'peer-device').save(
        Hold(
          id: 'h-remote',
          createdAt: DateTime.fromMillisecondsSinceEpoch(2000),
          updatedAt: DateTime.fromMillisecondsSinceEpoch(2000),
          deviceId: 'peer-device',
          duration: const Duration(seconds: 120),
          type: HoldType.max,
          lungVolume: LungVolume.full,
          isPb: false,
        ),
      );
      final remotePayload = await SyncRepository(
        database: remoteDb,
        deviceId: 'peer-device',
        holdsRepo: HoldsRepository(remoteDb, 'peer-device'),
        sessionsRepo: TableSessionsRepository(remoteDb, 'peer-device'),
        imstRepo: ImstSessionsRepository(remoteDb, 'peer-device'),
        tagsRepo: TagsRepository(remoteDb),
        settingsRepo: SettingsRepository(remoteDb),
      ).buildLocalPayload(appVersion: '1.0.0');

      final summary = await service.applyRemotePayload(remotePayload);

      expect(summary.counts.holdsAdded, 1);
      expect(summary.peerDeviceName, remotePayload.deviceName);
      final localHolds = await db.select(db.holds).get();
      expect(localHolds.map((h) => h.id), containsAll(['h-local', 'h-remote']));
    },
  );

  test('applyRemotePayload refuses a newer schema', () async {
    final payload = await service.buildLocalPayload();
    final bumped = SyncPayload.decode(
      payload.encode().replaceFirst(
        '"schemaVersion":${payload.schemaVersion}',
        '"schemaVersion":${payload.schemaVersion + 1}',
      ),
    );

    expect(
      () => service.applyRemotePayload(bumped),
      throwsA(
        isA<SyncPayloadException>().having(
          (e) => e.reason,
          'reason',
          SyncPayloadErrorReason.newerSchema,
        ),
      ),
    );
  });
}
