import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/sync_payload.dart';
import '../../domain/services/sync_merge_service.dart';
import '../db/app_database.dart' as db;
import '../db/database_provider.dart';
import 'device_id_provider.dart';
import 'holds_repository.dart';
import 'settings_repository.dart';
import 'table_sessions_repository.dart';
import 'tags_repository.dart';

/// DB-backed half of sync: reads the full local state into a [SyncPayload]
/// for export, and writes a [MergeResult] back in a single transaction for
/// import. The merge itself is pure and lives in [SyncMergeService].
class SyncRepository {
  SyncRepository({
    required db.AppDatabase database,
    required this.deviceId,
    required this._holdsRepo,
    required this._sessionsRepo,
    required this._tagsRepo,
    required this._settingsRepo,
  }) : _db = database;

  final db.AppDatabase _db;
  final String deviceId;
  final HoldsRepository _holdsRepo;
  final TableSessionsRepository _sessionsRepo;
  final TagsRepository _tagsRepo;
  final SettingsRepository _settingsRepo;

  /// Snapshots every row this device has — including soft-deleted ones,
  /// which need to travel so deletes can propagate to the other side.
  Future<SyncPayload> buildLocalPayload({required String appVersion}) async {
    final holdRows = await _db.select(_db.holds).get();
    final holdTagRows = await _db.select(_db.holdTags).get();
    final tagIdsByHold = <String, List<String>>{};
    for (final row in holdTagRows) {
      (tagIdsByHold[row.holdId] ??= []).add(row.tagId);
    }
    final holds = [
      for (final row in holdRows)
        SyncHoldRecord(
          id: row.id,
          createdAt: row.createdAt,
          updatedAt: row.updatedAt,
          deviceId: row.deviceId,
          durationMs: row.durationMs,
          contractionMs: row.contractionMs,
          type: row.type,
          lungVolume: row.lungVolume,
          prepMode: row.prepMode,
          notes: row.notes,
          isPb: row.isPb == 1,
          rating: row.rating,
          deleted: row.deleted == 1,
          tagIds: tagIdsByHold[row.id] ?? const [],
        ),
    ];

    final sessionRows = await _db.select(_db.tableSessions).get();
    final tableSessions = [
      for (final row in sessionRows)
        SyncTableSessionRecord(
          id: row.id,
          createdAt: row.createdAt,
          updatedAt: row.updatedAt,
          deviceId: row.deviceId,
          type: row.type,
          basedOnMaxMs: row.basedOnMaxMs,
          roundsTotal: row.roundsTotal,
          roundsCompleted: row.roundsCompleted,
          roundDetails: row.roundDetails,
          deleted: row.deleted == 1,
        ),
    ];

    final tagRows = await _db.select(_db.tags).get();
    final tags = [
      for (final row in tagRows)
        SyncTagRecord(
          id: row.id,
          labelKey: row.labelKey,
          createdAt: row.createdAt,
          updatedAt: row.updatedAt,
          deleted: row.deleted == 1,
        ),
    ];

    return SyncPayload(
      schemaVersion: _db.schemaVersion,
      exportedAt: DateTime.now().millisecondsSinceEpoch,
      deviceId: deviceId,
      deviceName: await _settingsRepo.getDeviceName() ?? 'This device',
      appVersion: appVersion,
      holds: holds,
      tableSessions: tableSessions,
      tags: tags,
    );
  }

  /// Writes a merge result and recomputes PB flags in one transaction, so
  /// a failure partway through leaves the database untouched. Also stamps
  /// `last_sync_at`/`last_sync_peer_name`.
  Future<void> applyMerge({
    required MergeResult result,
    required String peerDeviceName,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _db.transaction(() async {
      // Tags before holds: hold_tags rows carry a foreign key to tags, so
      // a hold referencing a brand-new tag would violate it otherwise.
      await _tagsRepo.upsertAll(result.tags);
      await _holdsRepo.upsertAll(result.holds);
      await _sessionsRepo.upsertAll(result.tableSessions);
      await _recomputePbFlags();
      await _settingsRepo.setLastSync(
        atMs: now,
        peerDeviceName: peerDeviceName,
      );
    });
  }

  /// Re-derives the PB flag over the merged set and republishes the current
  /// max. The recompute itself lives on [HoldsRepository] because the save and
  /// delete paths need exactly the same thing; only the `current_max_ms`
  /// write is sync's own concern.
  Future<void> _recomputePbFlags() async {
    final bestMs = await _holdsRepo.recomputePbFlags();
    if (bestMs != null) await _settingsRepo.setCurrentMaxMs(bestMs);
  }
}

final syncRepositoryProvider = FutureProvider<SyncRepository>((ref) async {
  final database = ref.watch(databaseProvider);
  final deviceId = await ref.watch(deviceIdProvider.future);
  final holdsRepo = await ref.watch(holdsRepositoryProvider.future);
  final sessionsRepo = await ref.watch(tableSessionsRepositoryProvider.future);
  final tagsRepo = ref.watch(tagsRepositoryProvider);
  final settingsRepo = ref.watch(settingsRepositoryProvider);
  return SyncRepository(
    database: database,
    deviceId: deviceId,
    holdsRepo: holdsRepo,
    sessionsRepo: sessionsRepo,
    tagsRepo: tagsRepo,
    settingsRepo: settingsRepo,
  );
});
