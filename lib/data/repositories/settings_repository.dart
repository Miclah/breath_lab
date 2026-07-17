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

  /// Prep breathing duration in seconds. Falls back to a mode-appropriate
  /// default (30s for Short, 120s for Full) until the user overrides it —
  /// switching between Short and Full re-suggests that default.
  Future<int> getPrepBreathingDurationSeconds(PrepMode mode) async {
    final stored = await _get('prep_breathing_duration_s');
    if (stored != null) return int.parse(stored);
    return mode == PrepMode.short ? 30 : 120;
  }

  Future<void> setPrepBreathingDurationSeconds(int seconds) =>
      _set('prep_breathing_duration_s', seconds.toString());

  /// Breathing ratio as (inhaleSeconds, exhaleSeconds). Defaults to 4:6.
  Future<(int, int)> getBreathingRatio() async {
    final inhale = await _get('breathing_ratio_inhale_s');
    final exhale = await _get('breathing_ratio_exhale_s');
    return (
      inhale == null ? 4 : int.parse(inhale),
      exhale == null ? 6 : int.parse(exhale),
    );
  }

  Future<void> setBreathingRatio(int inhaleSeconds, int exhaleSeconds) async {
    await _set('breathing_ratio_inhale_s', inhaleSeconds.toString());
    await _set('breathing_ratio_exhale_s', exhaleSeconds.toString());
  }
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

/// Prep breathing duration in seconds. Invalidate after writing to refresh.
final prepBreathingDurationSecondsProvider = FutureProvider<int>((ref) async {
  final mode = await ref.watch(defaultPrepModeProvider.future);
  return ref
      .watch(settingsRepositoryProvider)
      .getPrepBreathingDurationSeconds(mode);
});

/// Breathing ratio as (inhaleSeconds, exhaleSeconds). Invalidate after
/// writing to refresh.
final breathingRatioProvider = FutureProvider<(int, int)>((ref) {
  return ref.watch(settingsRepositoryProvider).getBreathingRatio();
});
