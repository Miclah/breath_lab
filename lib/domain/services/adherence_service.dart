import '../models/hold.dart';
import '../models/imst_session.dart';
import '../models/table_session.dart';

/// One part of the target weekly shape, and how this week measured against it.
class AdherenceComponent {
  const AdherenceComponent({required this.actual, required this.target});

  /// What happened this week — days trained, or sessions logged.
  final int actual;

  /// The research-derived target for the week (`RESEARCH_ALIGNMENT.md` §5).
  final int target;

  /// 0..1 — capped, so overshooting a target neither helps nor hurts.
  double get ratio =>
      target == 0 ? 1 : (actual / target).clamp(0.0, 1.0).toDouble();

  bool get met => actual >= target;
}

/// How well one Monday-start week matched the target training shape from
/// `RESEARCH_ALIGNMENT.md` §5: 2 max-hold days, 2–3 tables, IMST on most
/// days, 1 rest or stretch day. An apnea walk is optional and does not
/// affect the score.
///
/// **A logged rest or stretch day counts toward [recovery]** — it never
/// breaks the figure the way a consecutive-days streak does. That is the
/// whole reason this replaces the streak headline (§3.1).
class WeeklyAdherence {
  const WeeklyAdherence({
    required this.weekStart,
    required this.maxHolds,
    required this.tables,
    required this.imst,
    required this.recovery,
  });

  final DateTime weekStart;

  /// Distinct days this week with at least one max hold. Target 2.
  final AdherenceComponent maxHolds;

  /// CO₂/O₂ table sessions this week. Target 2 (the research caps them at 3).
  final AdherenceComponent tables;

  /// Distinct days this week with an IMST session. Target 5 (Craighead:
  /// 5–6 days a week).
  final AdherenceComponent imst;

  /// Distinct days this week with a logged rest or stretch session. Target 1.
  final AdherenceComponent recovery;

  List<AdherenceComponent> get components => [maxHolds, tables, imst, recovery];

  /// Mean of the four component ratios, 0..1.
  double get score =>
      components.fold<double>(0, (sum, c) => sum + c.ratio) / components.length;

  /// Whole-percent form for display.
  int get percent => (score * 100).round();
}

class AdherenceService {
  const AdherenceService._();

  static const maxHoldTarget = 2;
  static const tablesTarget = 2;
  static const imstTarget = 5;
  static const recoveryTarget = 1;

  static DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  /// The Monday 00:00 of the week containing [date].
  static DateTime weekStartFor(DateTime date) {
    final d = _dateOnly(date);
    return d.subtract(Duration(days: d.weekday - 1));
  }

  /// Adherence for the week containing [now] (defaults to today).
  static WeeklyAdherence currentWeek({
    required List<Hold> holds,
    required List<TableSession> tables,
    required List<ImstSession> imst,
    DateTime? now,
  }) => forWeek(
    weekStart: weekStartFor(now ?? DateTime.now()),
    holds: holds,
    tables: tables,
    imst: imst,
  );

  static WeeklyAdherence forWeek({
    required DateTime weekStart,
    required List<Hold> holds,
    required List<TableSession> tables,
    required List<ImstSession> imst,
  }) {
    final start = _dateOnly(weekStart);
    final end = start.add(const Duration(days: 7));
    bool inWeek(DateTime dt) {
      final d = _dateOnly(dt);
      return !d.isBefore(start) && d.isBefore(end);
    }

    final maxHoldDays = <DateTime>{};
    final restDays = <DateTime>{};
    for (final h in holds) {
      if (!inWeek(h.createdAt)) continue;
      final day = _dateOnly(h.createdAt);
      if (h.type == HoldType.max) maxHoldDays.add(day);
      if (h.type == HoldType.rest || h.type == HoldType.stretch) {
        restDays.add(day);
      }
    }

    final tableCount = tables.where((t) => inWeek(t.createdAt)).length;

    final imstDays = <DateTime>{
      for (final s in imst)
        if (inWeek(s.createdAt)) _dateOnly(s.createdAt),
    };

    return WeeklyAdherence(
      weekStart: start,
      maxHolds: AdherenceComponent(
        actual: maxHoldDays.length,
        target: maxHoldTarget,
      ),
      tables: AdherenceComponent(actual: tableCount, target: tablesTarget),
      imst: AdherenceComponent(actual: imstDays.length, target: imstTarget),
      recovery: AdherenceComponent(
        actual: restDays.length,
        target: recoveryTarget,
      ),
    );
  }
}
