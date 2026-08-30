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

class _Peer {
  _Peer(this.name) {
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

  Future<void> addHold(String id, int at) => holds.save(
    Hold(
      id: id,
      createdAt: DateTime.fromMillisecondsSinceEpoch(at),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(at),
      deviceId: name,
      duration: const Duration(seconds: 100),
      type: HoldType.max,
      lungVolume: LungVolume.full,
      isPb: false,
    ),
  );

  Future<Set<String>> holdIds() async =>
      (await db.select(db.holds).get()).map((h) => h.id).toSet();
}

void main() {
  late _Peer host;
  late _Peer phone;
  late LanSyncHost server;

  setUp(() {
    host = _Peer('pc');
    phone = _Peer('phone');
  });

  tearDown(() async {
    await server.stop();
    await host.db.close();
    await phone.db.close();
  });

  Future<LanPairing> startHost({List<String> hosts = const ['127.0.0.1']}) {
    server = LanSyncHost(
      host.service,
      deviceName: 'PC',
      resolveHosts: () async => hosts,
    );
    return server.start();
  }

  test('exchange converges both databases in one round trip', () async {
    await host.addHold('h-pc', 1000);
    await phone.addHold('h-phone', 2000);
    final pairing = await startHost();

    final summary = await LanSyncClient(phone.service).exchange(pairing);

    expect(summary.counts.holdsAdded, 1);
    expect(await host.holdIds(), containsAll(['h-pc', 'h-phone']));
    expect(await phone.holdIds(), containsAll(['h-pc', 'h-phone']));
  });

  test(
    'exchange skips an unreachable address and lands on a reachable one',
    () async {
      await host.addHold('h-pc', 1000);
      final realPairing = await startHost();
      final pairing = LanPairing(
        hosts: ['10.255.255.1', ...realPairing.hosts],
        port: realPairing.port,
        token: realPairing.token,
        deviceName: realPairing.deviceName,
      );

      final summary = await LanSyncClient(
        phone.service,
        connectTimeout: const Duration(milliseconds: 400),
      ).exchange(pairing);

      expect(summary.counts.holdsAdded, 1);
      expect(await phone.holdIds(), contains('h-pc'));
    },
  );

  test('a wrong token surfaces an expired-code message', () async {
    final pairing = await startHost();
    final wrong = LanPairing(
      hosts: pairing.hosts,
      port: pairing.port,
      token: 'wrong-token',
      deviceName: pairing.deviceName,
    );

    await expectLater(
      LanSyncClient(phone.service).exchange(wrong),
      throwsA(
        isA<LanSyncClientException>().having(
          (e) => e.message,
          'message',
          contains('expired'),
        ),
      ),
    );
  });

  test('all addresses unreachable throws a same-network hint', () async {
    final pairing = await startHost(hosts: ['10.255.255.1']);

    await expectLater(
      LanSyncClient(
        phone.service,
        connectTimeout: const Duration(milliseconds: 400),
      ).exchange(pairing),
      throwsA(
        isA<LanSyncClientException>().having(
          (e) => e.message,
          'message',
          contains('same Wi-Fi'),
        ),
      ),
    );
  });
}
