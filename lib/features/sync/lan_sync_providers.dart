import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/holds_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/table_sessions_repository.dart';
import '../../data/repositories/tags_repository.dart';
import '../../domain/services/lan_sync_host.dart';
import '../../domain/services/sync_service.dart';

/// Refresh every provider that reads data a sync could have changed. Called
/// by both sync paths — file import already had its own copy of this list.
void invalidateAfterSync(WidgetRef ref) {
  ref.invalidate(allHoldsProvider);
  ref.invalidate(allTableSessionsProvider);
  ref.invalidate(holdTagIdsProvider);
  ref.invalidate(holdTagCountsProvider);
  ref.invalidate(builtInTagsProvider);
  ref.invalidate(currentMaxMsProvider);
  ref.invalidate(lastSyncInfoProvider);
}

/// Builds the [LanSyncHost] the status provider drives. A seam for tests to
/// substitute a host with a fixed address list instead of the real network.
final lanSyncHostFactoryProvider =
    Provider<LanSyncHost Function(SyncService syncService, String deviceName)>(
      (ref) =>
          (syncService, deviceName) =>
              LanSyncHost(syncService, deviceName: deviceName),
    );

/// Owns one [LanSyncHost] for the lifetime of the host screen.
///
/// Starts the server as soon as the screen subscribes and stops it on
/// dispose, so leaving the screen — or a hot reload — always frees the
/// socket. A failure to start (no network) arrives as a stream error.
final lanSyncHostStatusProvider = StreamProvider.autoDispose<LanSyncHostStatus>(
  (ref) async* {
    final syncService = await ref.watch(syncServiceProvider.future);
    final deviceName = await ref.watch(deviceNameProvider.future);

    final host = ref.watch(lanSyncHostFactoryProvider)(syncService, deviceName);
    ref.onDispose(host.stop);

    final relay = StreamController<LanSyncHostStatus>();
    final sub = host.status.listen(
      relay.add,
      onError: relay.addError,
      onDone: relay.close,
    );
    ref.onDispose(sub.cancel);
    ref.onDispose(relay.close);

    unawaited(
      Future(() async {
        try {
          await host.start();
        } catch (error, stack) {
          relay.addError(error, stack);
        }
      }),
    );

    yield* relay.stream;
  },
);
