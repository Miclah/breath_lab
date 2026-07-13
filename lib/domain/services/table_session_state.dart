import '../models/table_session.dart';
import 'co2_table_calculator.dart';

enum TableSessionPhase { idle, hold, rest, done }

class TableSessionState {
  const TableSessionState({
    this.phase = TableSessionPhase.idle,
    this.type,
    this.basedOnMaxMs = 0,
    this.rounds = const [],
    this.currentRoundIndex = 0,
    this.elapsed = Duration.zero,
    this.completedRounds = const [],
  });

  final TableSessionPhase phase;
  final TableType? type;

  /// The current max (in ms) this session's rounds were calculated from.
  final int basedOnMaxMs;

  /// The planned rounds for this session, from the calculator.
  final List<TableRoundPlan> rounds;

  final int currentRoundIndex;

  /// Time elapsed in the current hold or rest phase. Updated every 50 ms.
  final Duration elapsed;

  /// Actual results for rounds completed (or ended early) so far.
  final List<TableRoundDetail> completedRounds;

  bool get isIdle => phase == TableSessionPhase.idle;
  bool get isHolding => phase == TableSessionPhase.hold;
  bool get isResting => phase == TableSessionPhase.rest;
  bool get isDone => phase == TableSessionPhase.done;

  TableRoundPlan? get currentRound =>
      currentRoundIndex < rounds.length ? rounds[currentRoundIndex] : null;

  TableSessionState copyWith({
    TableSessionPhase? phase,
    TableType? type,
    int? basedOnMaxMs,
    List<TableRoundPlan>? rounds,
    int? currentRoundIndex,
    Duration? elapsed,
    List<TableRoundDetail>? completedRounds,
  }) {
    return TableSessionState(
      phase: phase ?? this.phase,
      type: type ?? this.type,
      basedOnMaxMs: basedOnMaxMs ?? this.basedOnMaxMs,
      rounds: rounds ?? this.rounds,
      currentRoundIndex: currentRoundIndex ?? this.currentRoundIndex,
      elapsed: elapsed ?? this.elapsed,
      completedRounds: completedRounds ?? this.completedRounds,
    );
  }
}
