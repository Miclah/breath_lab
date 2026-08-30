import 'package:breath_lab/data/db/app_database.dart';
import 'package:breath_lab/data/repositories/holds_repository.dart';
import 'package:breath_lab/data/repositories/imst_sessions_repository.dart';
import 'package:breath_lab/data/repositories/settings_repository.dart';
import 'package:breath_lab/data/repositories/sync_repository.dart';
import 'package:breath_lab/data/repositories/table_sessions_repository.dart';
import 'package:breath_lab/data/repositories/tags_repository.dart';
import 'package:breath_lab/domain/services/lan_sync_host.dart';
import 'package:breath_lab/domain/services/sync_service.dart';
import 'package:breath_lab/features/sync/lan_sync_providers.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the status provider starts a host and emits LanSyncServing', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final service = SyncService(
      syncRepo: SyncRepository(
        database: db,
        deviceId: 'pc',
        holdsRepo: HoldsRepository(db, 'pc'),
        sessionsRepo: TableSessionsRepository(db, 'pc'),
        imstRepo: ImstSessionsRepository(db, 'pc'),
        tagsRepo: TagsRepository(db),
        settingsRepo: SettingsRepository(db),
      ),
      database: db,
      appVersion: '1.0.0',
    );

    final container = ProviderContainer(
      overrides: [
        syncServiceProvider.overrideWith((ref) async => service),
        deviceNameProvider.overrideWith(_FixedName.new),
        lanSyncHostFactoryProvider.overrideWithValue(
          (svc, name) => LanSyncHost(
            svc,
            deviceName: name,
            resolveHosts: () async => ['127.0.0.1'],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    // Keep the autoDispose provider alive while we wait for its first value.
    final sub = container.listen(
      lanSyncHostStatusProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(sub.close);

    final first = await container.read(lanSyncHostStatusProvider.future);
    expect(first, isA<LanSyncServing>());
    expect((first as LanSyncServing).pairing.hosts, ['127.0.0.1']);
    expect(first.pairing.deviceName, 'The PC');
  });
}

class _FixedName extends DeviceNameNotifier {
  @override
  Future<String> build() async => 'The PC';
}
