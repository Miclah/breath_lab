import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/hold.dart';
import '../../domain/services/timer_service.dart';

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
  }

  /// Stop the hold and move to done state.
  void stop() {
    _holdStopwatch.stop();
    _stopTicker();
    state = state.copyWith(
      phase: TimerPhase.done,
      holdElapsed: _holdStopwatch.elapsed,
    );
  }

  /// Record first contraction timestamp relative to hold start.
  /// Subsequent calls are no-ops (only first contraction is tracked).
  void markContraction() {
    if (!state.isHolding) return;
    if (state.contractionTime != null) return;
    HapticFeedback.lightImpact();
    state = state.copyWith(contractionTime: _holdStopwatch.elapsed);
  }

  /// Return to idle, clearing all elapsed times.
  void reset() {
    _stopTicker();
    _holdStopwatch.reset();
    _prepStopwatch.reset();
    state = const TimerState();
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
