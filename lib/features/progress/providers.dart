import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/holds_repository.dart';
import '../../data/repositories/table_sessions_repository.dart';
import '../../domain/models/hold.dart';
import '../../domain/models/table_session.dart';
import '../../domain/services/stats_service.dart';

/// The single longest max hold ever recorded.
final allTimePbProvider = Provider<Duration?>((ref) {
  final holds = ref.watch(allHoldsProvider).valueOrNull ?? const [];
  return StatsService.allTimePB(holds);
});

/// Average max hold duration over the last 30 days.
final avg30dProvider = Provider<Duration?>((ref) {
  final holds = ref.watch(allHoldsProvider).valueOrNull ?? const [];
  return StatsService.averageWithinDays(holds, 30);
});

/// Consecutive training days ending today (or yesterday).
final currentStreakProvider = Provider<int>((ref) {
  final holds = ref.watch(allHoldsProvider).valueOrNull ?? const [];
  final tables = ref.watch(allTableSessionsProvider).valueOrNull ?? const [];
  return StatsService.currentStreak(holds, tables);
});

/// Per-day session counts (holds + table sessions) for the calendar
/// heatmap, plus the totals shown in its legend.
class HeatmapData {
  const HeatmapData({
    required this.countsByDate,
    required this.totalSessions,
    required this.bestWeekDays,
  });

  /// Date-only key (year/month/day) → number of sessions that day.
  final Map<DateTime, int> countsByDate;
  final int totalSessions;
  final int bestWeekDays;
}

final heatmapDataProvider = Provider<HeatmapData>((ref) {
  final holds = ref.watch(allHoldsProvider).valueOrNull ?? const [];
  final tables = ref.watch(allTableSessionsProvider).valueOrNull ?? const [];
  return computeHeatmapData(holds, tables);
});

/// Windows [holds]/[tables] down to the last 12 Monday-start weeks
/// (including the current, possibly partial, week) and aggregates them.
HeatmapData computeHeatmapData(
  List<Hold> holds,
  List<TableSession> tables, {
  DateTime? now,
}) {
  final today = _dateOnly(now ?? DateTime.now());
  final currentWeekStart = today.subtract(Duration(days: today.weekday - 1));
  final windowStart = currentWeekStart.subtract(const Duration(days: 7 * 11));

  final windowHolds = holds
      .where((h) => !_dateOnly(h.createdAt).isBefore(windowStart))
      .toList();
  final windowTables = tables
      .where((t) => !_dateOnly(t.createdAt).isBefore(windowStart))
      .toList();

  final counts = <DateTime, int>{};
  for (final createdAt in [
    ...windowHolds.map((h) => h.createdAt),
    ...windowTables.map((t) => t.createdAt),
  ]) {
    final date = _dateOnly(createdAt);
    counts[date] = (counts[date] ?? 0) + 1;
  }

  return HeatmapData(
    countsByDate: counts,
    totalSessions: counts.values.fold(0, (sum, n) => sum + n),
    bestWeekDays: StatsService.bestWeek(windowHolds, windowTables),
  );
}

DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
