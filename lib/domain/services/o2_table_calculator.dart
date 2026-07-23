import 'co2_table_calculator.dart';

/// Computes an O₂ table: fixed rest, with holds ramping linearly from
/// maxHoldPercent/rounds on round 1 up to maxHoldPercent of max on the
/// final round.
class O2TableCalculator {
  static List<TableRoundPlan> compute({
    required int maxMs,
    required int rounds,
    required double maxHoldPercent,
    required int restS,
  }) {
    final restMs = restS * 1000;
    return List.generate(rounds, (i) {
      final holdPercent = maxHoldPercent * (i + 1) / rounds;
      final rawHoldMs = (maxMs * holdPercent).round();
      final holdMs = rawHoldMs < CO2TableCalculator.minHoldMs
          ? CO2TableCalculator.minHoldMs
          : rawHoldMs;
      return TableRoundPlan(holdMs: holdMs, restMs: restMs);
    });
  }
}
