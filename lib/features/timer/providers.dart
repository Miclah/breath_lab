import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/holds_repository.dart';
import '../../domain/models/hold.dart';
import '../../domain/services/timer_service.dart';
import '../tables/providers.dart'
    show hapticsServiceProvider, wakelockServiceProvider;

class TimerNotifier extends Notifier<TimerState> {
  final _holdStopwatch = Stopwatch();
  final _prepStopwatch = Stopwatch();
  Timer? _ticker;

  @override
  TimerState build() => const TimerState();

  /// Enter prep phase. Prep completion calls [beginHold].
  void startPrep(PrepMode mode) {
    _prepStopwatch
      ..reset()
      ..start();
    _holdStopwatch.reset();
    state = TimerState(phase: TimerPhase.prep, prepMode: mode);
    _startTicker();
  }

  /// Transition from prep to active hold. Called by prep widgets when ready.
  void beginHold() {
    _prepStopwatch.stop();
    _holdStopwatch
      ..reset()
      ..start();
    state = state.copyWith(phase: TimerPhase.hold, holdElapsed: Duration.zero);
    ref.read(hapticsServiceProvider).holdStart();
    ref.read(wakelockServiceProvider).enable();
  }

  /// Stop the hold and move to done state.
  void stop() {
    _holdStopwatch.stop();
    _stopTicker();
    state = state.copyWith(
      phase: TimerPhase.done,
      holdElapsed: _holdStopwatch.elapsed,
    );
    ref.read(hapticsServiceProvider).holdStop();
    // The hold is over, so nothing needs the screen kept awake any more.
    // Waiting for reset() would hold the wakelock for as long as the result
    // screen sits unanswered.
    ref.read(wakelockServiceProvider).disable();
  }

  /// Record first contraction timestamp relative to hold start.
  /// Subsequent calls are no-ops (only first contraction is tracked).
  void markContraction() {
    if (!state.isHolding) return;
    if (state.contractionTime != null) return;
    ref.read(hapticsServiceProvider).contraction();
    state = state.copyWith(contractionTime: _holdStopwatch.elapsed);
  }

  /// Return to idle, clearing all elapsed times.
  void reset() {
    _stopTicker();
    _holdStopwatch.reset();
    _prepStopwatch.reset();
    state = const TimerState();
    ref.read(wakelockServiceProvider).disable();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 50), (_) {
      state = state.copyWith(
        holdElapsed: _holdStopwatch.elapsed,
        prepElapsed: _prepStopwatch.elapsed,
      );
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }
}

final timerProvider = NotifierProvider<TimerNotifier, TimerState>(
  TimerNotifier.new,
);

/// Session-local prep mode selection. Null means "use the user's saved default".
final selectedPresetProvider = StateProvider<PrepMode?>((ref) => null);

/// Session-local lung volume override on the result screen.
/// Null means "use the user's saved default from settings".
final selectedLungVolumeProvider = StateProvider<LungVolume?>((ref) => null);

/// IDs of built-in tags selected on the result screen.
final selectedTagIdsProvider = StateProvider<Set<String>>((ref) => const {});

/// Custom tag label texts added by the user on the result screen (not yet persisted).
final pendingCustomTagsProvider = StateProvider<List<String>>(
  (ref) => const [],
);

/// Today's max holds, oldest first — the session the user is in the middle
/// of, in the order they did it.
///
/// Table rounds are excluded: eight co2 rounds would swamp the row and they
/// are not what "today's holds" means on the timer screen.
final todaysHoldsProvider = Provider<List<Hold>>((ref) {
  final holds = ref.watch(allHoldsProvider).valueOrNull ?? const [];
  return todaysHolds(holds);
});

/// Free text typed into the result screen's note field, before the hold is
/// saved. Empty means no note — `Hold.notes` stays null rather than storing
/// a blank string.
final pendingNoteProvider = StateProvider<String>((ref) => '');

/// The most recent saved max hold — the "last" a fresh result is compared
/// against. Null before the very first one.
///
/// [allHoldsProvider] is newest-first, and the hold on the result screen is
/// not saved yet, so the head of that list is genuinely the previous one.
final lastMaxHoldProvider = Provider<Hold?>((ref) {
  final holds = ref.watch(allHoldsProvider).valueOrNull ?? const [];
  for (final hold in holds) {
    if (hold.type == HoldType.max) return hold;
  }
  return null;
});

/// Pure form of [todaysHoldsProvider], with an injectable clock.
List<Hold> todaysHolds(List<Hold> holds, {DateTime? now}) {
  final today = now ?? DateTime.now();
  final result =
      holds
          .where(
            (h) =>
                h.type == HoldType.max &&
                h.createdAt.year == today.year &&
                h.createdAt.month == today.month &&
                h.createdAt.day == today.day,
          )
          .toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  return result;
}
