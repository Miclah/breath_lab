import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:breath_lab/features/timer/timer_ring.dart';
import 'package:breath_lab/theme/colors.dart';

/// The pair of sweeps that determines what the ring looks like at [value].
(double, double) _shape(double value) =>
    (TimerRing.arcFraction(value), TimerRing.overflowFraction(value));

void main() {
  group('TimerRing sweeps', () {
    test('half a PB is a half sweep and no overflow', () {
      expect(_shape(0.5), (0.5, 0.0));
    });

    test('at the PB the outer ring closes and the overflow is still empty', () {
      expect(_shape(1.0), (1.0, 0.0));
    });

    test('past the PB the overflow arc opens', () {
      expect(_shape(1.5), (1.0, 0.5));
    });

    test('the four states in the acceptance criteria all differ', () {
      final shapes = [0.5, 1.0, 1.5, 3.0].map(_shape).toList();
      expect(shapes.toSet(), hasLength(4));
    });

    test('a hold with no PB to measure against draws nothing', () {
      expect(_shape(0.0), (0.0, 0.0));
    });

    test('both arcs stay closed rather than wrapping a third time', () {
      // Whatever the caller passes, the sweeps stay in range - an arc of
      // more than a full turn would paint over itself.
      expect(_shape(9.0), (1.0, 1.0));
    });
  });

  group('TimerRing colour', () {
    const c = BreathLabColors.dark;

    Color colorAt({required int pbSeconds, required int atSeconds}) {
      final elapsed = Duration(seconds: atSeconds);
      return TimerRing.ringColor(atSeconds / pbSeconds, elapsed, c);
    }

    test('a 20s PB does not turn the ring red in the first 15 seconds', () {
      for (var t = 1; t <= 15; t++) {
        expect(
          colorAt(pbSeconds: 20, atSeconds: t),
          isNot(c.danger),
          reason: '${t}s into a hold against a 20s best',
        );
      }
    });

    test('a freshly reset one-second best does not paint red at all', () {
      // The case from the screenshots: ratio 4.0 two seconds in.
      expect(colorAt(pbSeconds: 1, atSeconds: 2), c.primary);
      expect(colorAt(pbSeconds: 1, atSeconds: 20), c.primary);
    });

    test('a real best still escalates once both floors are passed', () {
      expect(colorAt(pbSeconds: 120, atSeconds: 60), c.primary);
      // 90s is exactly 75% - the start of the amber ramp, so still teal.
      expect(colorAt(pbSeconds: 120, atSeconds: 90), c.primary);
      expect(colorAt(pbSeconds: 120, atSeconds: 100), isNot(c.primary));
      expect(colorAt(pbSeconds: 120, atSeconds: 120), c.danger);
    });

    test('past the ratio but short of the floor stays calm', () {
      // 40s is past a 20s best twice over, but still under the danger floor.
      expect(colorAt(pbSeconds: 20, atSeconds: 40), isNot(c.danger));
      expect(colorAt(pbSeconds: 20, atSeconds: 45), c.danger);
    });
  });
}
