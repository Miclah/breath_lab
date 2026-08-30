import 'dart:convert';
import 'dart:io';

import 'package:breath_lab/data/db/app_database.dart' hide Hold;
import 'package:breath_lab/data/repositories/holds_repository.dart';
import 'package:breath_lab/data/repositories/imst_sessions_repository.dart';
import 'package:breath_lab/data/repositories/settings_repository.dart';
import 'package:breath_lab/data/repositories/sync_repository.dart';
import 'package:breath_lab/data/repositories/table_sessions_repository.dart';
import 'package:breath_lab/data/repositories/tags_repository.dart';
import 'package:breath_lab/domain/models/hold.dart';
import 'package:breath_lab/domain/models/sync_payload.dart';
import 'package:breath_lab/domain/services/lan_sync_host.dart';
import 'package:breath_lab/domain/services/sync_service.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

class _Peer {
  _Peer(this.name) {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    holds = HoldsRepository(db, name);
    sync = SyncRepository(
      database: db,
      deviceId: name,
      holdsRepo: holds,
      sessionsRepo: TableSessionsRepository(db, name),
      imstRepo: ImstSessionsRepository(db, name),
      tagsRepo: TagsRepository(db),
      settingsRepo: SettingsRepository(db),
    );
    service = SyncService(syncRepo: sync, database: db, appVersion: '1.0.0');
  }

  final String name;
  late final AppDatabase db;
  late final HoldsRepository holds;
  late final SyncRepository sync;
  late final SyncService service;

  Future<void> addHold(String id, int seconds, int at) => holds.save(
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

  Future<LanSyncHost> startServer() async {
    server = LanSyncHost(
      host.service,
      deviceName: 'The PC',
      resolveHosts: () async => ['127.0.0.1'],
    );
    return server;
  }

  Future<HttpClientResponse> post(int port, String token, String body) async {
    final client = HttpClient();
    final req = await client.post('127.0.0.1', port, '/sync');
    req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
    req.write(body);
    final res = await req.close();
    client.close();
    return res;
  }

  test('a full exchange converges both sides and emits done', () async {
    await host.addHold('h-pc', 90, 1000);
    await phone.addHold('h-phone', 120, 2000);
    await startServer();

    final statuses = <LanSyncHostStatus>[];
    server.status.listen(statuses.add);

    final pairing = await server.start();
    final phonePayload = await phone.service.buildLocalPayload();

    final res = await post(pairing.port, pairing.token, phonePayload.encode());
    expect(res.statusCode, 200);
    final responseBody = await utf8.decodeStream(res);

    // The phone applies the host's answer.
    await phone.service.applyRemotePayload(SyncPayload.decode(responseBody));

    expect(await host.holdIds(), containsAll(['h-pc', 'h-phone']));
    expect(await phone.holdIds(), containsAll(['h-pc', 'h-phone']));

    await Future<void>.delayed(Duration.zero);
    expect(statuses.whereType<LanSyncHostDone>(), isNotEmpty);
    expect(statuses.last, isA<LanSyncHostDone>());
  });

  test('a wrong bearer token is refused with 401', () async {
    await startServer();
    final pairing = await server.start();
    final res = await post(pairing.port, 'not-the-token', '{}');
    expect(res.statusCode, 401);
  });

  test('the server stops after one completed exchange', () async {
    await startServer();
    final pairing = await server.start();

    final first = await post(
      pairing.port,
      pairing.token,
      (await phone.service.buildLocalPayload()).encode(),
    );
    expect(first.statusCode, 200);
    await first.drain<void>();
    await Future<void>.delayed(const Duration(milliseconds: 50));

    // The socket is closed — a second connection cannot be made.
    await expectLater(
      post(pairing.port, pairing.token, '{}'),
      throwsA(isA<SocketException>()),
    );
  });

  test('start throws when there is no network interface', () async {
    server = LanSyncHost(
      host.service,
      deviceName: 'PC',
      resolveHosts: () async => [],
    );
    await expectLater(server.start(), throwsA(isA<LanSyncHostException>()));
  });
}
