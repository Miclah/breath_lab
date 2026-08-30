import 'package:flutter_test/flutter_test.dart';
import 'package:breath_lab/domain/models/hold.dart';
import 'package:breath_lab/domain/models/imst_session.dart';
import 'package:breath_lab/features/progress/providers.dart';

ImstSession _imst(DateTime createdAt, {int breaths = 30}) => ImstSession(
  id: 'imst-${createdAt.millisecondsSinceEpoch}',
  createdAt: createdAt,
  updatedAt: createdAt,
  deviceId: 'device',
  breaths: breaths,
);

Hold _hold(
  DateTime createdAt, {
  Duration duration = const Duration(minutes: 1),
  HoldType type = HoldType.max,
  LungVolume lungVolume = LungVolume.full,
  Duration? contractionTime,
  bool isPb = false,
}) {
  return Hold(
    id: 'id-${createdAt.millisecondsSinceEpoch}-${duration.inMilliseconds}',
    createdAt: createdAt,
    updatedAt: createdAt,
    contractionTime: contractionTime,
    deviceId: 'device',
    duration: duration,
    type: type,
    lungVolume: lungVolume,
    isPb: isPb,
  );
}

void main() {
  group('computeHeatmapData', () {
    // 2026-07-13 is a Monday; the window covers 12 Monday-start weeks
    // ending with this one, i.e. 2026-04-20 through 2026-07-19.
    final now = DateTime(2026, 7, 13, 12);

    test('counts sessions per day within the 12-week window', () {
      final holds = [
        _hold(now),
        _hold(now),
        _hold(now.subtract(const Duration(days: 1))),
      ];
      final data = computeHeatmapData(holds, [], now: now);

      expect(data.countsByDate[DateTime(2026, 7, 13)], 2);
      expect(data.countsByDate[DateTime(2026, 7, 12)], 1);
      expect(data.totalSessions, 3);
    });

    test('excludes sessions older than 12 weeks before the current week', () {
      final holds = [_hold(now), _hold(now.subtract(const Duration(days: 90)))];
      final data = computeHeatmapData(holds, [], now: now);

      expect(data.totalSessions, 1);
    });

    test('bestWeekDays reflects the busiest week inside the window', () {
      final monday = DateTime(2026, 7, 13);
      final holds = [
        _hold(monday),
        _hold(monday.add(const Duration(days: 1))),
        _hold(monday.add(const Duration(days: 2))),
      ];
      final data = computeHeatmapData(holds, [], now: now);

      expect(data.bestWeekDays, 3);
    });

    test('is empty for no history', () {
      final data = computeHeatmapData([], [], now: now);

      expect(data.countsByDate, isEmpty);
      expect(data.totalSessions, 0);
      expect(data.bestWeekDays, 0);
    });

    test('an IMST session fills its day and counts toward the best week', () {
      final monday = DateTime(2026, 7, 13);
      final data = computeHeatmapData(
        [_hold(monday)],
        [],
        imst: [
          _imst(monday.add(const Duration(days: 1))),
          _imst(monday.add(const Duration(days: 2))),
        ],
        now: now,
      );

      expect(data.countsByDate[DateTime(2026, 7, 14)], 1);
      expect(data.totalSessions, 3);
      expect(data.bestWeekDays, 3);
    });
  });

  group('computeDailyHoldStats', () {
    final now = DateTime(2026, 7, 13, 12);

    test('computes best and average duration per day', () {
      final holds = [
        _hold(now, duration: const Duration(minutes: 2)),
        _hold(now, duration: const Duration(minutes: 4)),
      ];
      final stats = computeDailyHoldStats(holds, now: now);

      expect(stats, hasLength(1));
      expect(stats.single.best, const Duration(minutes: 4));
      expect(stats.single.average, const Duration(minutes: 3));
    });

    test('ignores non-max holds and other lung volumes', () {
      final holds = [
        _hold(now, type: HoldType.co2),
        _hold(now, lungVolume: LungVolume.frc),
        _hold(now, duration: const Duration(minutes: 1, seconds: 30)),
      ];
      final stats = computeDailyHoldStats(holds, now: now);

      expect(stats, hasLength(1));
      expect(stats.single.best, const Duration(minutes: 1, seconds: 30));
    });

    test('excludes holds outside the day window and marks PB days', () {
      final holds = [
        _hold(now, isPb: true),
        _hold(now.subtract(const Duration(days: 40))),
      ];
      final stats = computeDailyHoldStats(holds, days: 30, now: now);

      expect(stats, hasLength(1));
      expect(stats.single.hasPb, isTrue);
    });

    test('dayIndex reflects true position on the window, skipping gaps', () {
      final holds = [_hold(now), _hold(now.subtract(const Duration(days: 5)))];
      final stats = computeDailyHoldStats(holds, days: 30, now: now);

      expect(stats.map((s) => s.dayIndex).toList(), [24, 29]);
    });

    test('bestStruggle is the longest total-minus-contraction that day', () {
      final holds = [
        // struggle 90s
        _hold(
          now,
          duration: const Duration(minutes: 2, seconds: 30),
          contractionTime: const Duration(minutes: 1),
        ),
        // struggle 40s — shorter, so not the winner
        _hold(
          now,
          duration: const Duration(minutes: 2),
          contractionTime: const Duration(minutes: 1, seconds: 20),
        ),
        // no marker — contributes nothing to struggle
        _hold(now, duration: const Duration(minutes: 5)),
      ];
      final stats = computeDailyHoldStats(holds, now: now);

      expect(stats.single.bestStruggle, const Duration(seconds: 90));
    });

    test('bestStruggle is zero on a day with no contraction markers', () {
      final stats = computeDailyHoldStats([_hold(now)], now: now);
      expect(stats.single.bestStruggle, Duration.zero);
    });

    test('is empty for no history', () {
      expect(computeDailyHoldStats([], now: now), isEmpty);
    });
  });

  group('computeRetestPrompt', () {
    final now = DateTime(2026, 7, 30, 12);

    test('hidden when the last max hold is recent', () {
      final p = computeRetestPrompt([
        _hold(now.subtract(const Duration(days: 10))),
      ], now: now);
      expect(p.show, isFalse);
    });

    test('shows once the last max hold is 3+ weeks old', () {
      final p = computeRetestPrompt([
        _hold(now.subtract(const Duration(days: 24))),
      ], now: now);
      expect(p.show, isTrue);
      expect(p.weeksSinceLastMax, 3);
    });

    test('a recent dismissal quiets it', () {
      final dismissed = now
          .subtract(const Duration(days: 2))
          .millisecondsSinceEpoch;
      final p = computeRetestPrompt(
        [_hold(now.subtract(const Duration(days: 30)))],
        dismissedAtMs: dismissed,
        now: now,
      );
      expect(p.show, isFalse);
    });

    test('a stale dismissal no longer suppresses it', () {
      final dismissed = now
          .subtract(const Duration(days: 10))
          .millisecondsSinceEpoch;
      final p = computeRetestPrompt(
        [_hold(now.subtract(const Duration(days: 30)))],
        dismissedAtMs: dismissed,
        now: now,
      );
      expect(p.show, isTrue);
    });

    test('hidden with no max holds at all', () {
      expect(computeRetestPrompt(const [], now: now).show, isFalse);
    });
  });

  group('resolveChartWindowDays', () {
    final now = DateTime(2026, 7, 13, 12);

    test('returns fixedDays directly when given', () {
      final days = resolveChartWindowDays(
        [],
        volumes: const [LungVolume.full],
        fixedDays: 90,
        now: now,
      );
      expect(days, 90);
    });

    test('spans from the earliest qualifying hold to today when unfixed', () {
      final holds = [
        _hold(now),
        _hold(now.subtract(const Duration(days: 44))),
        // Different volume -- should not extend the window.
        _hold(
          now.subtract(const Duration(days: 200)),
          lungVolume: LungVolume.frc,
        ),
      ];
      final days = resolveChartWindowDays(
        holds,
        volumes: const [LungVolume.full],
        now: now,
      );
      expect(days, 45);
    });

    test('falls back to 30 when there are no qualifying holds', () {
      final days = resolveChartWindowDays(
        [],
        volumes: const [LungVolume.full],
        now: now,
      );
      expect(days, 30);
    });
  });
}
