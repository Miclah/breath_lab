import 'package:breath_lab/data/db/app_database.dart' hide Hold;
import 'package:breath_lab/data/repositories/holds_repository.dart';
import 'package:breath_lab/data/repositories/imst_sessions_repository.dart';
import 'package:breath_lab/data/repositories/settings_repository.dart';
import 'package:breath_lab/data/repositories/sync_repository.dart';
import 'package:breath_lab/data/repositories/table_sessions_repository.dart';
import 'package:breath_lab/data/repositories/tags_repository.dart';
import 'package:breath_lab/domain/models/hold.dart';
import 'package:breath_lab/domain/models/lan_pairing.dart';
import 'package:breath_lab/domain/services/lan_sync_client.dart';
import 'package:breath_lab/domain/services/lan_sync_host.dart';
import 'package:breath_lab/domain/services/sync_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class _Device {
  _Device(this.name) {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    holds = HoldsRepository(db, name);
    service = SyncService(
      syncRepo: SyncRepository(
        database: db,
        deviceId: name,
        holdsRepo: holds,
        sessionsRepo: TableSessionsRepository(db, name),
        imstRepo: ImstSessionsRepository(db, name),
        tagsRepo: TagsRepository(db),
        settingsRepo: SettingsRepository(db),
      ),
      database: db,
      appVersion: '1.0.0',
    );
  }

  final String name;
  late final AppDatabase db;
  late final HoldsRepository holds;
  late final SyncService service;

  Future<void> add(String id, int seconds, int at) => holds.save(
    Hold(
      id: id,
      createdAt: DateTime.fromMillisecondsSinceEpoch(at),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(at),
      deviceId: name,
      duration: Duration(seconds: seconds),
      type: HoldType.max,
      lungVolume: LungVolume.full,
      isPb: false,
    ),
  );

  Future<Map<String, int>> holdsById() async => {
    for (final h in await db.select(db.holds).get()) h.id: h.durationMs,
  };
}

void main() {
  test(
    'QR hop then exchange: both devices converge, including an edit',
    () async {
      final pc = _Device('pc');
      final phone = _Device('phone');
      addTearDown(pc.db.close);
      addTearDown(phone.db.close);

      // Prior shared history: the same hold on both, plus one unique each.
      await pc.add('shared', 90, 1000);
      await phone.add('shared', 90, 1000);
      await pc.add('pc-only', 100, 2000);
      await phone.add('phone-only', 110, 3000);
      // The phone later corrected the shared hold's length.
      await phone.holds.save(
        Hold(
          id: 'shared',
          createdAt: DateTime.fromMillisecondsSinceEpoch(1000),
          updatedAt: DateTime.fromMillisecondsSinceEpoch(9000),
          deviceId: 'phone',
          duration: const Duration(seconds: 95),
          type: HoldType.max,
          lungVolume: LungVolume.full,
          isPb: false,
        ),
      );

      final host = LanSyncHost(
        pc.service,
        deviceName: 'PC',
        resolveHosts: () async => ['127.0.0.1'],
      );
      addTearDown(host.stop);
      final pairing = await host.start();

      // The QR hop: encode on the PC, decode on the phone.
      final scanned = LanPairing.decode(pairing.encode());

      final summary = await LanSyncClient(phone.service).exchange(scanned);

      // Both sides now hold the union, and the phone's newer edit won on both.
      const expected = {
        'shared': 95000,
        'pc-only': 100000,
        'phone-only': 110000,
      };
      expect(await pc.holdsById(), expected);
      expect(await phone.holdsById(), expected);

      // The phone's summary reflects what it gained from the PC.
      expect(summary.counts.holdsAdded, 1); // pc-only
    },
  );

  test('starting from empty on one side pulls the whole history', () async {
    final pc = _Device('pc');
    final fresh = _Device('fresh');
    addTearDown(pc.db.close);
    addTearDown(fresh.db.close);

    await pc.add('a', 80, 1000);
    await pc.add('b', 120, 2000);

    final host = LanSyncHost(
      pc.service,
      deviceName: 'PC',
      resolveHosts: () async => ['127.0.0.1'],
    );
    addTearDown(host.stop);
    final pairing = await host.start();

    await LanSyncClient(
      fresh.service,
    ).exchange(LanPairing.decode(pairing.encode()));

    expect((await fresh.holdsById()).keys, containsAll(['a', 'b']));
  });
}
