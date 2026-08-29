import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/holds_repository.dart';
import '../../data/repositories/imst_sessions_repository.dart';
import '../../data/repositories/table_sessions_repository.dart';
import '../../domain/models/hold.dart';
import '../../domain/models/imst_session.dart';
import '../../domain/models/table_session.dart';
import '../../domain/services/adherence_service.dart';
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

/// Distinct training weeks — the demoted "streak" (`RESEARCH_ALIGNMENT.md`
/// §3.1), which no longer punishes a rest day.
final trainingWeeksProvider = Provider<int>((ref) {
  final holds = ref.watch(allHoldsProvider).valueOrNull ?? const [];
  final tables = ref.watch(allTableSessionsProvider).valueOrNull ?? const [];
  final imst = ref.watch(allImstSessionsProvider).valueOrNull ?? const [];
  return StatsService.trainingWeeks(holds, tables, imst: imst);
});

/// This week's structure adherence — the headline metric that replaces the
/// consecutive-days streak on the Timer screen.
final currentAdherenceProvider = Provider<WeeklyAdherence>((ref) {
  final holds = ref.watch(allHoldsProvider).valueOrNull ?? const [];
  final tables = ref.watch(allTableSessionsProvider).valueOrNull ?? const [];
  final imst = ref.watch(allImstSessionsProvider).valueOrNull ?? const [];
  return AdherenceService.currentWeek(holds: holds, tables: tables, imst: imst);
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
  final imst = ref.watch(allImstSessionsProvider).valueOrNull ?? const [];
  return computeHeatmapData(holds, tables, imst: imst);
});

/// Windows [holds]/[tables] down to the last 12 Monday-start weeks
/// (including the current, possibly partial, week) and aggregates them.
HeatmapData computeHeatmapData(
  List<Hold> holds,
  List<TableSession> tables, {
  List<ImstSession> imst = const [],
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
  final windowImst = imst
      .where((s) => !_dateOnly(s.createdAt).isBefore(windowStart))
      .toList();

  final counts = <DateTime, int>{};
  for (final createdAt in [
    ...windowHolds.map((h) => h.createdAt),
    ...windowTables.map((t) => t.createdAt),
    ...windowImst.map((s) => s.createdAt),
  ]) {
    final date = _dateOnly(createdAt);
    counts[date] = (counts[date] ?? 0) + 1;
  }

  return HeatmapData(
    countsByDate: counts,
    totalSessions: counts.values.fold(0, (sum, n) => sum + n),
    bestWeekDays: StatsService.bestWeek(
      windowHolds,
      windowTables,
      imst: windowImst,
    ),
  );
}

DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

/// Best/average max-hold duration for a single day on the progress chart.
class DailyHoldStat {
  const DailyHoldStat({
    required this.date,
    required this.dayIndex,
    required this.best,
    required this.average,
    required this.bestStruggle,
    required this.hasPb,
  });

  final DateTime date;

  /// Position on the chart's fixed 0..days-1 x-axis. Days with no
  /// qualifying holds are omitted from the series entirely, but the
  /// surviving points keep their true index so gaps read as gaps.
  final int dayIndex;
  final Duration best;
  final Duration average;

  /// The longest struggle phase (total − time-to-first-contraction) among
  /// the day's holds that had a contraction marked. `Duration.zero` when no
  /// hold that day carried a marker — `RESEARCH_ALIGNMENT.md` §2 puts most
  /// of a novice's measured gain here, not in [best].
  final Duration bestStruggle;

  final bool hasPb;
}

/// Per-day best/average duration for max holds of [lungVolume], over the
/// last [days] days ending today.
List<DailyHoldStat> computeDailyHoldStats(
  List<Hold> holds, {
  LungVolume lungVolume = LungVolume.full,
  int days = 30,
  DateTime? now,
}) {
  final today = _dateOnly(now ?? DateTime.now());
  final windowStart = today.subtract(Duration(days: days - 1));

  final durationsByDay = <DateTime, List<Hold>>{};
  for (final hold in holds) {
    if (hold.type != HoldType.max || hold.lungVolume != lungVolume) continue;
    final date = _dateOnly(hold.createdAt);
    if (date.isBefore(windowStart) || date.isAfter(today)) continue;
    (durationsByDay[date] ??= []).add(hold);
  }

  final stats = durationsByDay.entries.map((entry) {
    final dayHolds = entry.value;
    final totalMs = dayHolds.fold<int>(
      0,
      (sum, h) => sum + h.duration.inMilliseconds,
    );
    final struggles = [
      for (final h in dayHolds)
        if (h.contractionTime != null && h.duration > h.contractionTime!)
          h.duration - h.contractionTime!,
    ];
    return DailyHoldStat(
      date: entry.key,
      dayIndex: entry.key.difference(windowStart).inDays,
      best: dayHolds.map((h) => h.duration).reduce((a, b) => a > b ? a : b),
      average: Duration(milliseconds: totalMs ~/ dayHolds.length),
      bestStruggle: struggles.isEmpty
          ? Duration.zero
          : struggles.reduce((a, b) => a > b ? a : b),
      hasPb: dayHolds.any((h) => h.isPb),
    );
  }).toList();

  stats.sort((a, b) => a.dayIndex.compareTo(b.dayIndex));
  return stats;
}

/// The chart's lung volume filter. Null means "All" (every volume
/// overlaid); a specific value shows only that volume. Defaults to Full,
/// per PRD §7.3.
final chartLungFilterProvider = StateProvider<LungVolume?>(
  (ref) => LungVolume.full,
);

/// One line series on the progress chart: a lung volume and its per-day
/// stats within the chart's window.
class ChartSeries {
  const ChartSeries({required this.lungVolume, required this.stats});

  final LungVolume lungVolume;
  final List<DailyHoldStat> stats;
}

/// The chart's time range: a fixed window, or "All" (spans from the
/// earliest qualifying hold to today).
enum ChartTimeRange {
  d30(30),
  d90(90),
  all(null);

  const ChartTimeRange(this.fixedDays);

  final int? fixedDays;
}

final chartTimeRangeProvider = StateProvider<ChartTimeRange>(
  (ref) => ChartTimeRange.d30,
);

/// The chart's x-axis window in days, resolving [ChartTimeRange.all] to
/// the span since the earliest qualifying hold.
final chartWindowDaysProvider = Provider<int>((ref) {
  final holds = ref.watch(allHoldsProvider).valueOrNull ?? const [];
  final filter = ref.watch(chartLungFilterProvider);
  final range = ref.watch(chartTimeRangeProvider);
  final volumes = filter == null ? LungVolume.values : [filter];
  return resolveChartWindowDays(
    holds,
    volumes: volumes,
    fixedDays: range.fixedDays,
  );
});

/// Days between the earliest max hold of [volumes] and today, inclusive.
/// Returns [fixedDays] directly when given, and falls back to 30 when
/// there is no qualifying hold at all (the chart shows its empty state).
int resolveChartWindowDays(
  List<Hold> holds, {
  required List<LungVolume> volumes,
  int? fixedDays,
  DateTime? now,
}) {
  if (fixedDays != null) return fixedDays;
  final today = _dateOnly(now ?? DateTime.now());
  DateTime? earliest;
  for (final hold in holds) {
    if (hold.type != HoldType.max || !volumes.contains(hold.lungVolume)) {
      continue;
    }
    final date = _dateOnly(hold.createdAt);
    if (earliest == null || date.isBefore(earliest)) earliest = date;
  }
  if (earliest == null) return 30;
  return today.difference(earliest).inDays + 1;
}

/// One series for the selected lung volume filter, or one per volume
/// when "All" is selected (overlaid on the chart).
final chartSeriesProvider = Provider<List<ChartSeries>>((ref) {
  final holds = ref.watch(allHoldsProvider).valueOrNull ?? const [];
  final filter = ref.watch(chartLungFilterProvider);
  final days = ref.watch(chartWindowDaysProvider);
  final volumes = filter == null ? LungVolume.values : [filter];
  return [
    for (final volume in volumes)
      ChartSeries(
        lungVolume: volume,
        stats: computeDailyHoldStats(holds, lungVolume: volume, days: days),
      ),
  ];
});
