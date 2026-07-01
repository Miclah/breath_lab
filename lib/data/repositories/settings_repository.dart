import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/app_database.dart' as db;
import '../db/database_provider.dart';
import '../../domain/models/hold.dart';

class SettingsRepository {
  SettingsRepository(this._db);

  final db.AppDatabase _db;

  Future<String?> _get(String key) async {
    final row = await (_db.select(
      _db.settings,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> _set(String key, String value) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _db
        .into(_db.settings)
        .insertOnConflictUpdate(
          db.SettingsCompanion(
            key: Value(key),
            value: Value(value),
            updatedAt: Value(now),
          ),
        );
  }

  Future<PrepMode> getDefaultPrepMode() async {
    final value = await _get('default_prep_mode');
    return PrepMode.fromDb(value) ?? PrepMode.threeSeconds;
  }

  Future<void> setDefaultPrepMode(PrepMode mode) =>
      _set('default_prep_mode', mode.dbValue);

  Future<LungVolume> getDefaultLungVolume() async {
    final value = await _get('default_lung_volume');
    return LungVolume.fromDb(value ?? 'full');
  }

  Future<void> setDefaultLungVolume(LungVolume volume) =>
      _set('default_lung_volume', volume.dbValue);

  Future<int?> getCurrentMaxMs() async {
    final value = await _get('current_max_ms');
    return value == null ? null : int.tryParse(value);
  }

  Future<void> setCurrentMaxMs(int ms) => _set('current_max_ms', ms.toString());
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(databaseProvider));
});

/// Current default prep mode. Invalidate after writing to refresh.
final defaultPrepModeProvider = FutureProvider<PrepMode>((ref) {
  return ref.watch(settingsRepositoryProvider).getDefaultPrepMode();
});

/// Current default lung volume. Invalidate after writing to refresh.
final defaultLungVolumeProvider = FutureProvider<LungVolume>((ref) {
  return ref.watch(settingsRepositoryProvider).getDefaultLungVolume();
});

/// All-time PB in milliseconds, null if no hold saved yet.
final currentMaxMsProvider = FutureProvider<int?>((ref) {
  return ref.watch(settingsRepositoryProvider).getCurrentMaxMs();
});
