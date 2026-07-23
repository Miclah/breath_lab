import 'package:flutter_test/flutter_test.dart';
import 'package:breath_lab/domain/services/co2_table_calculator.dart';
import 'package:breath_lab/domain/services/o2_table_calculator.dart';

void main() {
  group('O2TableCalculator', () {
    test('holds ramp linearly to maxHoldPercent on the final round', () {
      final rounds = O2TableCalculator.compute(
        maxMs: 100000,
        rounds: 8,
        maxHoldPercent: 0.8,
        restS: 120,
      );

      expect(rounds, hasLength(8));
      expect(rounds.map((r) => r.holdMs).toList(), [
        10000,
        20000,
        30000,
        40000,
        50000,
        60000,
        70000,
        80000,
      ]);
    });

    test('rest is fixed across all rounds', () {
      final rounds = O2TableCalculator.compute(
        maxMs: 100000,
        rounds: 8,
        maxHoldPercent: 0.8,
        restS: 120,
      );

      for (final round in rounds) {
        expect(round.restMs, 120000);
      }
    });

    test('rounds parameter of 1 holds at maxHoldPercent', () {
      final rounds = O2TableCalculator.compute(
        maxMs: 100000,
        rounds: 1,
        maxHoldPercent: 0.8,
        restS: 120,
      );

      expect(rounds.single.holdMs, 80000);
    });

    test('clamps an impossible near-zero first-round hold up to minHoldMs', () {
      final rounds = O2TableCalculator.compute(
        maxMs: 100000,
        rounds: 20,
        maxHoldPercent: 0.1,
        restS: 120,
      );

      expect(rounds.first.holdMs, CO2TableCalculator.minHoldMs);
    });
  });
}
