import 'package:flutter_test/flutter_test.dart';
import 'package:breath_lab/features/timer/timer_ring.dart';

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
}
