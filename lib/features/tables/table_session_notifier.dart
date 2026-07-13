import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/table_session.dart';
import '../../domain/services/co2_table_calculator.dart';
import '../../domain/services/table_session_state.dart';
import 'providers.dart';

class TableSessionNotifier extends Notifier<TableSessionState> {
  final _stopwatch = Stopwatch();
  Timer? _ticker;

  /// The rest-phase second (3, 2, or 1) the countdown tick was last played
  /// for, so each second only triggers one tick.
  int? _lastCountdownSecond;

  @override
  TableSessionState build() => const TableSessionState();

  /// Begin a session with the given planned rounds.
  void start(TableType type, List<TableRoundPlan> rounds) {
    _stopwatch
      ..reset()
      ..start();
    state = TableSessionState(
      phase: TableSessionPhase.hold,
      type: type,
      rounds: rounds,
    );
    _startTicker();
    ref.read(audioServiceProvider).playHoldStart();
    ref.read(hapticsServiceProvider).holdStart();
  }

  /// End the current hold before its planned duration. The actual (shorter)
  /// hold time is recorded and the session moves on to rest.
  void stopHoldEarly() {
    if (!state.isHolding) return;
    _completeHold(completed: false);
  }

  /// Return to idle, clearing all session progress.
  void reset() {
    _stopTicker();
    _stopwatch.reset();
    _lastCountdownSecond = null;
    state = const TableSessionState();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 50), (_) {
      final round = state.currentRound;
      if (round == null) return;
      final elapsedMs = _stopwatch.elapsed.inMilliseconds;

      if (state.isHolding && elapsedMs >= round.holdMs) {
        _completeHold(completed: true);
        return;
      }
      if (state.isResting) {
        final remainingMs = round.restMs - elapsedMs;
        if (remainingMs <= 0) {
          _completeRest();
          return;
        }
        final remainingS = (remainingMs / 1000).ceil();
        if (remainingS <= 3 && remainingS != _lastCountdownSecond) {
          _lastCountdownSecond = remainingS;
          ref.read(audioServiceProvider).playCountdownTick();
          ref.read(hapticsServiceProvider).countdownTick();
        }
      }
      state = state.copyWith(elapsed: _stopwatch.elapsed);
    });
  }

  void _completeHold({required bool completed}) {
    final round = state.currentRound!;
    final actualHoldMs = completed
        ? round.holdMs
        : _stopwatch.elapsed.inMilliseconds;
    final detail = TableRoundDetail(
      holdMs: actualHoldMs,
      restMs: 0,
      completed: completed,
    );
    _lastCountdownSecond = null;
    _stopwatch
      ..reset()
      ..start();
    state = state.copyWith(
      phase: TableSessionPhase.rest,
      elapsed: Duration.zero,
      completedRounds: [...state.completedRounds, detail],
    );
    ref.read(audioServiceProvider).playRestStart();
  }

  void _completeRest() {
    final round = state.currentRound!;
    final details = [...state.completedRounds];
    final last = details.removeLast();
    details.add(
      TableRoundDetail(
        holdMs: last.holdMs,
        restMs: round.restMs,
        completed: last.completed,
      ),
    );

    final nextIndex = state.currentRoundIndex + 1;
    if (nextIndex >= state.rounds.length) {
      _stopTicker();
      _stopwatch.stop();
      state = state.copyWith(
        phase: TableSessionPhase.done,
        elapsed: Duration.zero,
        completedRounds: details,
      );
      ref.read(audioServiceProvider).playRoundDone();
      ref.read(hapticsServiceProvider).sessionComplete();
      return;
    }

    _stopwatch
      ..reset()
      ..start();
    state = state.copyWith(
      phase: TableSessionPhase.hold,
      currentRoundIndex: nextIndex,
      elapsed: Duration.zero,
      completedRounds: details,
    );
    ref.read(audioServiceProvider).playHoldStart();
    ref.read(hapticsServiceProvider).holdStart();
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }
}

final tableSessionProvider =
    NotifierProvider<TableSessionNotifier, TableSessionState>(
      TableSessionNotifier.new,
    );
