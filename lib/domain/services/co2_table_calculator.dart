class TableRoundPlan {
  const TableRoundPlan({required this.holdMs, required this.restMs});

  final int holdMs;
  final int restMs;
}

/// Computes a CO₂ table: a fixed hold (percent of max) repeated across
/// [rounds], with rest decreasing by [restDecrementS] each round down to
/// zero on the final round.
class CO2TableCalculator {
  static List<TableRoundPlan> compute({
    required int maxMs,
    required int rounds,
    required double holdPercent,
    required int restDecrementS,
  }) {
    final holdMs = (maxMs * holdPercent).round();
    return List.generate(rounds, (i) {
      final restS = restDecrementS * (rounds - 1 - i);
      return TableRoundPlan(holdMs: holdMs, restMs: restS * 1000);
    });
  }
}
