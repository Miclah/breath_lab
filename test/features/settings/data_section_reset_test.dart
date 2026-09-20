import 'package:breath_lab/data/db/app_database.dart' hide Hold, ImstSession;
import 'package:breath_lab/data/db/database_provider.dart';
import 'package:breath_lab/data/repositories/holds_repository.dart';
import 'package:breath_lab/data/repositories/imst_sessions_repository.dart';
import 'package:breath_lab/data/repositories/table_sessions_repository.dart';
import 'package:breath_lab/domain/models/hold.dart';
import 'package:breath_lab/domain/models/imst_session.dart';
import 'package:breath_lab/features/progress/providers.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Regression test for the reset bug reported against the running app: after
/// "reset all data", the Progress screen (30d avg, weeks trained, heatmap)
/// kept showing pre-reset numbers. The DB was actually empty — the bug was
/// that these providers fetch straight from the repository providers rather
/// than from `allHoldsProvider`/`allTableSessionsProvider`, so reset's old
/// invalidation list never touched them. This exercises the exact provider
/// graph `_confirmReset` in data_section.dart drives, without touching any
/// real on-device database.
void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
  });

  tearDown(() {
    container.dispose();
    db.close();
  });

  /// Keeps reading [provider] until [ready] accepts the value, i.e. until
  /// the private recent-window FutureProviders it's built on have resolved.
  Future<T> settled<T>(
    ProviderListenable<T> provider,
    bool Function(T) ready,
  ) async {
    for (var i = 0; i < 100; i++) {
      final value = container.read(provider);
      if (ready(value)) return value;
      await Future<void>.delayed(const Duration(milliseconds: 5));
    }
    throw StateError('$provider did not settle in time');
  }

  test('reset clears the Progress screen, not just the DB', () async {
    final now = DateTime.now();
    final holdsRepo = await container.read(holdsRepositoryProvider.future);
    final imstRepo = await container.read(
      imstSessionsRepositoryProvider.future,
    );

    await holdsRepo.save(
      Hold(
        id: 'h1',
        createdAt: now,
        updatedAt: now,
        deviceId: 'device',
        duration: const Duration(seconds: 90),
        type: HoldType.max,
        lungVolume: LungVolume.full,
        isPb: false,
      ),
    );
    await imstRepo.save(
      ImstSession(
        id: 'i1',
        createdAt: now,
        updatedAt: now,
        deviceId: 'device',
        breaths: 30,
      ),
    );

    // Sanity check: before reset, Progress actually shows the seeded data —
    // otherwise this test would trivially pass either way.
    final before = await settled(
      heatmapDataProvider,
      (d) => d.totalSessions > 0,
    );
    expect(before.totalSessions, 2);
    final avgBefore = await settled(avg30dProvider, (d) => d != null);
    expect(avgBefore, const Duration(seconds: 90));
    final weeksBefore = await settled(trainingWeeksProvider, (w) => w > 0);
    expect(weeksBefore, greaterThan(0));

    // The reset itself, plus exactly the invalidation list from
    // `_ResetAllDataRow._confirmReset` in data_section.dart.
    await db.resetAllData();
    container.invalidate(holdsRepositoryProvider);
    container.invalidate(tableSessionsRepositoryProvider);
    container.invalidate(imstSessionsRepositoryProvider);

    final after = await settled(
      heatmapDataProvider,
      (d) => d.totalSessions == 0,
    );
    expect(after.totalSessions, 0);
    expect(after.bestWeekDays, 0);
    final avgAfter = await settled(avg30dProvider, (d) => d == null);
    expect(avgAfter, isNull);
    final weeksAfter = await settled(trainingWeeksProvider, (w) => w == 0);
    expect(weeksAfter, 0);
  });

  test(
    'without the fix (invalidating only the old list) Progress stays stale',
    () async {
      final now = DateTime.now();
      final holdsRepo = await container.read(holdsRepositoryProvider.future);
      await holdsRepo.save(
        Hold(
          id: 'h1',
          createdAt: now,
          updatedAt: now,
          deviceId: 'device',
          duration: const Duration(seconds: 90),
          type: HoldType.max,
          lungVolume: LungVolume.full,
          isPb: false,
        ),
      );
      await settled(avg30dProvider, (d) => d != null);

      await db.resetAllData();
      // The pre-fix reset only ever invalidated the *derived* list
      // providers, never the repository providers underneath the private
      // recent-window ones — so avg30dProvider must still read the stale,
      // cached value.
      container.invalidate(allHoldsProvider);

      // Give any (wrongly expected) recompute a chance to happen, then
      // assert it didn't: this documents the bug this test guards against.
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(container.read(avg30dProvider), const Duration(seconds: 90));
    },
  );
}
