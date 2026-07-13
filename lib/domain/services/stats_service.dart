import '../models/hold.dart';
import '../models/table_session.dart';

/// Pure functions computing progress stats from hold and table session
/// history. No I/O, no Riverpod — callers wire this to providers.
class StatsService {
  const StatsService._();

  /// The single longest max hold ever recorded, or null if there are none.
  static Duration? allTimePB(List<Hold> holds) {
    final durations = _maxDurations(holds);
    if (durations.isEmpty) return null;
    return durations.reduce((a, b) => a > b ? a : b);
  }

  /// The longest max hold within the last [days] days, or null if there
  /// were no max holds in that window.
  static Duration? pbWithinDays(List<Hold> holds, int days, {DateTime? now}) {
    final durations = _maxDurationsWithinDays(holds, days, now: now);
    if (durations.isEmpty) return null;
    return durations.reduce((a, b) => a > b ? a : b);
  }

  /// The average max hold duration within the last [days] days, or null if
  /// there were no max holds in that window.
  static Duration? averageWithinDays(
    List<Hold> holds,
    int days, {
    DateTime? now,
  }) {
    final durations = _maxDurationsWithinDays(holds, days, now: now);
    if (durations.isEmpty) return null;
    final totalMs = durations.fold<int>(0, (sum, d) => sum + d.inMilliseconds);
    return Duration(milliseconds: totalMs ~/ durations.length);
  }

  /// Consecutive training days ending today (or yesterday, if today has no
  /// session yet), counted backward. Zero if yesterday and today are both
  /// empty.
  static int currentStreak(
    List<Hold> holds,
    List<TableSession> tables, {
    DateTime? now,
  }) {
    final dates = _sessionDates(holds, tables);
    var day = _dateOnly(now ?? DateTime.now());
    if (!dates.contains(day)) {
      day = day.subtract(const Duration(days: 1));
      if (!dates.contains(day)) return 0;
    }
    var streak = 0;
    while (dates.contains(day)) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// The longest run of consecutive training days across all history.
  static int longestStreak(List<Hold> holds, List<TableSession> tables) {
    final dates = _sessionDates(holds, tables);
    if (dates.isEmpty) return 0;
    final sorted = dates.toList()..sort();
    var longest = 1;
    var current = 1;
    for (var i = 1; i < sorted.length; i++) {
      final gap = sorted[i].difference(sorted[i - 1]).inDays;
      current = gap == 1 ? current + 1 : 1;
      if (current > longest) longest = current;
    }
    return longest;
  }

  /// The most training days recorded within any single Monday-start week.
  static int bestWeek(List<Hold> holds, List<TableSession> tables) {
    final dates = _sessionDates(holds, tables);
    if (dates.isEmpty) return 0;
    final countsByWeekStart = <DateTime, int>{};
    for (final date in dates) {
      final weekStart = date.subtract(Duration(days: date.weekday - 1));
      countsByWeekStart[weekStart] = (countsByWeekStart[weekStart] ?? 0) + 1;
    }
    return countsByWeekStart.values.reduce((a, b) => a > b ? a : b);
  }

  static List<Duration> _maxDurations(List<Hold> holds) => holds
      .where((h) => h.type == HoldType.max)
      .map((h) => h.duration)
      .toList();

  static List<Duration> _maxDurationsWithinDays(
    List<Hold> holds,
    int days, {
    DateTime? now,
  }) {
    final cutoff = (now ?? DateTime.now()).subtract(Duration(days: days));
    return holds
        .where((h) => h.type == HoldType.max && h.createdAt.isAfter(cutoff))
        .map((h) => h.duration)
        .toList();
  }

  static Set<DateTime> _sessionDates(
    List<Hold> holds,
    List<TableSession> tables,
  ) {
    return {
      ...holds.map((h) => _dateOnly(h.createdAt)),
      ...tables.map((t) => _dateOnly(t.createdAt)),
    };
  }

  static DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);
}
