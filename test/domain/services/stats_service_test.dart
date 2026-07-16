import 'package:flutter_test/flutter_test.dart';
import 'package:breath_lab/domain/models/hold.dart';
import 'package:breath_lab/domain/models/table_session.dart';
import 'package:breath_lab/domain/services/stats_service.dart';

Hold _hold({
  required Duration duration,
  required DateTime createdAt,
  HoldType type = HoldType.max,
}) {
  return Hold(
    id: 'id-${createdAt.millisecondsSinceEpoch}-${duration.inMilliseconds}',
    createdAt: createdAt,
    updatedAt: createdAt,
    deviceId: 'device',
    duration: duration,
    type: type,
    lungVolume: LungVolume.full,
    isPb: false,
  );
}

TableSession _tableSession(DateTime createdAt) {
  return TableSession(
    id: 'table-${createdAt.millisecondsSinceEpoch}',
    createdAt: createdAt,
    updatedAt: createdAt,
    deviceId: 'device',
    type: TableType.co2,
    basedOnMaxMs: 60000,
    roundsTotal: 7,
    roundsCompleted: 7,
    roundDetails: const [],
  );
}

void main() {
  final now = DateTime(2026, 7, 13, 12);

  group('allTimePB', () {
    test('returns null for empty history', () {
      expect(StatsService.allTimePB([]), isNull);
    });

    test('returns the longest max hold, ignoring non-max types', () {
      final holds = [
        _hold(duration: const Duration(minutes: 2), createdAt: now),
        _hold(
          duration: const Duration(minutes: 5),
          createdAt: now,
          type: HoldType.co2,
        ),
        _hold(
          duration: const Duration(minutes: 3),
          createdAt: now.subtract(const Duration(days: 10)),
        ),
      ];
      expect(StatsService.allTimePB(holds), const Duration(minutes: 3));
    });
  });

  group('pbWithinDays', () {
    test('excludes holds older than the window', () {
      final holds = [
        _hold(
          duration: const Duration(minutes: 4),
          createdAt: now.subtract(const Duration(days: 40)),
        ),
        _hold(
          duration: const Duration(minutes: 2),
          createdAt: now.subtract(const Duration(days: 5)),
        ),
      ];
      expect(
        StatsService.pbWithinDays(holds, 30, now: now),
        const Duration(minutes: 2),
      );
    });

    test('returns null when no holds fall in the window', () {
      final holds = [
        _hold(
          duration: const Duration(minutes: 4),
          createdAt: now.subtract(const Duration(days: 40)),
        ),
      ];
      expect(StatsService.pbWithinDays(holds, 30, now: now), isNull);
    });
  });

  group('averageWithinDays', () {
    test('averages only holds within the window', () {
      final holds = [
        _hold(
          duration: const Duration(minutes: 1),
          createdAt: now.subtract(const Duration(days: 1)),
        ),
        _hold(
          duration: const Duration(minutes: 3),
          createdAt: now.subtract(const Duration(days: 2)),
        ),
        _hold(
          duration: const Duration(minutes: 9),
          createdAt: now.subtract(const Duration(days: 40)),
        ),
      ];
      expect(
        StatsService.averageWithinDays(holds, 30, now: now),
        const Duration(minutes: 2),
      );
    });
  });

  group('currentStreak', () {
    test('counts consecutive days ending today', () {
      final holds = [
        _hold(duration: const Duration(minutes: 1), createdAt: now),
        _hold(
          duration: const Duration(minutes: 1),
          createdAt: now.subtract(const Duration(days: 1)),
        ),
        _hold(
          duration: const Duration(minutes: 1),
          createdAt: now.subtract(const Duration(days: 2)),
        ),
      ];
      expect(StatsService.currentStreak(holds, [], now: now), 3);
    });

    test('still counts if today has no session but yesterday does', () {
      final holds = [
        _hold(
          duration: const Duration(minutes: 1),
          createdAt: now.subtract(const Duration(days: 1)),
        ),
      ];
      expect(StatsService.currentStreak(holds, [], now: now), 1);
    });

    test('is zero if both today and yesterday are empty', () {
      final holds = [
        _hold(
          duration: const Duration(minutes: 1),
          createdAt: now.subtract(const Duration(days: 3)),
        ),
      ];
      expect(StatsService.currentStreak(holds, [], now: now), 0);
    });

    test('counts table sessions toward the streak', () {
      final tables = [_tableSession(now)];
      expect(StatsService.currentStreak([], tables, now: now), 1);
    });
  });

  group('longestStreak', () {
    test('finds the longest run even if it is not the most recent', () {
      final holds = [
        _hold(duration: const Duration(minutes: 1), createdAt: now),
        _hold(
          duration: const Duration(minutes: 1),
          createdAt: now.subtract(const Duration(days: 20)),
        ),
        _hold(
          duration: const Duration(minutes: 1),
          createdAt: now.subtract(const Duration(days: 21)),
        ),
        _hold(
          duration: const Duration(minutes: 1),
          createdAt: now.subtract(const Duration(days: 22)),
        ),
      ];
      expect(StatsService.longestStreak(holds, []), 3);
    });

    test('is zero for empty history', () {
      expect(StatsService.longestStreak([], []), 0);
    });
  });

  group('bestWeek', () {
    test('returns the most training days in any single Monday-start week', () {
      // 2026-07-13 is a Monday.
      final monday = DateTime(2026, 7, 13);
      final holds = [
        _hold(duration: const Duration(minutes: 1), createdAt: monday),
        _hold(
          duration: const Duration(minutes: 1),
          createdAt: monday.add(const Duration(days: 1)),
        ),
        _hold(
          duration: const Duration(minutes: 1),
          createdAt: monday.add(const Duration(days: 2)),
        ),
        // Lone session in a different week.
        _hold(
          duration: const Duration(minutes: 1),
          createdAt: monday.subtract(const Duration(days: 7)),
        ),
      ];
      expect(StatsService.bestWeek(holds, []), 3);
    });

    test('is zero for empty history', () {
      expect(StatsService.bestWeek([], []), 0);
    });
  });
}
