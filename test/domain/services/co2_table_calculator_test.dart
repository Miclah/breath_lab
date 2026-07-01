import 'package:flutter_test/flutter_test.dart';
import 'package:breath_lab/domain/services/co2_table_calculator.dart';

void main() {
  group('CO2TableCalculator', () {
    test('holds are constant at holdPercent of max', () {
      final rounds = CO2TableCalculator.compute(
        maxMs: 120000,
        rounds: 7,
        holdPercent: 0.5,
        restDecrementS: 15,
      );

      expect(rounds, hasLength(7));
      for (final round in rounds) {
        expect(round.holdMs, 60000);
      }
    });

    test('rest decreases by restDecrementS each round, ending at zero', () {
      final rounds = CO2TableCalculator.compute(
        maxMs: 120000,
        rounds: 7,
        holdPercent: 0.5,
        restDecrementS: 15,
      );

      expect(rounds.map((r) => r.restMs).toList(), [
        90000,
        75000,
        60000,
        45000,
        30000,
        15000,
        0,
      ]);
    });

    test('rounds parameter of 1 produces a single round with zero rest', () {
      final rounds = CO2TableCalculator.compute(
        maxMs: 100000,
        rounds: 1,
        holdPercent: 0.5,
        restDecrementS: 15,
      );

      expect(rounds, hasLength(1));
      expect(rounds.single.restMs, 0);
    });
  });
}
