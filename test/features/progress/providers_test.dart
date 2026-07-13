import 'package:flutter_test/flutter_test.dart';
import 'package:breath_lab/domain/models/hold.dart';
import 'package:breath_lab/features/progress/providers.dart';

Hold _hold(DateTime createdAt) {
  return Hold(
    id: 'id-${createdAt.millisecondsSinceEpoch}',
    createdAt: createdAt,
    updatedAt: createdAt,
    deviceId: 'device',
    duration: const Duration(minutes: 1),
    type: HoldType.max,
    lungVolume: LungVolume.full,
    isPb: false,
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
  });
}
