import 'package:breath_lab/domain/models/hold.dart';
import 'package:breath_lab/domain/services/plateau_service.dart';
import 'package:flutter_test/flutter_test.dart';

final _now = DateTime(2026, 8, 1, 12);

Hold _hold({
  required int daysAgo,
  required Duration duration,
  HoldType type = HoldType.max,
  LungVolume lungVolume = LungVolume.full,
}) {
  final at = _now.subtract(Duration(days: daysAgo));
  return Hold(
    id: 'h-$daysAgo-${duration.inSeconds}-${type.name}-${lungVolume.name}',
    createdAt: at,
    updatedAt: at,
    deviceId: 'd',
    duration: duration,
    type: type,
    lungVolume: lungVolume,
    isPb: false,
  );
}

void main() {
  group('PlateauService.detect', () {
    test('no plateau without a hold in the previous 28-day window', () {
      final holds = [
        for (var d = 0; d < 20; d += 3)
          _hold(
            daysAgo: d,
            duration: Duration(seconds: 120 + d),
          ),
      ];
      expect(PlateauService.detect(holds, now: _now).plateaued, isFalse);
    });

    test('flat best across both windows is a plateau', () {
      final holds = [
        for (var week = 0; week < 8; week++)
          _hold(
            daysAgo: week * 7,
            duration: const Duration(minutes: 2, seconds: 30),
          ),
      ];
      final status = PlateauService.detect(holds, now: _now);
      expect(status.plateaued, isTrue);
      expect(status.recentBest, const Duration(minutes: 2, seconds: 30));
      expect(status.previousBest, const Duration(minutes: 2, seconds: 30));
    });

    test('an improving best is not a plateau', () {
      final holds = [
        for (var week = 0; week < 8; week++)
          _hold(
            daysAgo: week * 7,
            // more recent weeks = smaller daysAgo = longer holds
            duration: Duration(seconds: 200 - week * 5),
          ),
      ];
      expect(PlateauService.detect(holds, now: _now).plateaued, isFalse);
    });

    test('a recent regression is still a plateau (recent <= previous)', () {
      final holds = [
        _hold(daysAgo: 40, duration: const Duration(seconds: 180)),
        _hold(daysAgo: 5, duration: const Duration(seconds: 160)),
      ];
      expect(PlateauService.detect(holds, now: _now).plateaued, isTrue);
    });

    test('ignores non-Full volumes and non-max holds', () {
      final holds = [
        _hold(daysAgo: 40, duration: const Duration(seconds: 100)),
        _hold(daysAgo: 5, duration: const Duration(seconds: 100)),
        // A longer recent FRC hold must not rescue the plateau.
        _hold(
          daysAgo: 3,
          duration: const Duration(seconds: 300),
          lungVolume: LungVolume.frc,
        ),
        _hold(
          daysAgo: 3,
          duration: const Duration(seconds: 300),
          type: HoldType.co2,
        ),
      ];
      expect(PlateauService.detect(holds, now: _now).plateaued, isTrue);
    });

    test('empty history is not a plateau', () {
      expect(PlateauService.detect(const [], now: _now).plateaued, isFalse);
    });
  });
}
