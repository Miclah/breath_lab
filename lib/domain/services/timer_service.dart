import '../../domain/models/hold.dart';

enum TimerPhase { idle, prep, hold, done }

class TimerState {
  const TimerState({
    this.phase = TimerPhase.idle,
    this.holdElapsed = Duration.zero,
    this.prepElapsed = Duration.zero,
    this.contractionTime,
    this.prepMode,
  });

  final TimerPhase phase;

  /// Time elapsed during the hold. Updated every 50 ms while holding.
  final Duration holdElapsed;

  /// Time elapsed during prep. Updated every 50 ms while in prep phase.
  final Duration prepElapsed;

  /// Timestamp of the first contraction relative to hold start; null until marked.
  final Duration? contractionTime;

  /// Prep mode chosen for the current or last hold.
  final PrepMode? prepMode;

  bool get isIdle => phase == TimerPhase.idle;
  bool get isPrep => phase == TimerPhase.prep;
  bool get isHolding => phase == TimerPhase.hold;
  bool get isDone => phase == TimerPhase.done;

  /// Struggle-phase duration: from first contraction to hold end.
  Duration? get strugglePhase {
    if (contractionTime == null) return null;
    if (!isDone) return null;
    final struggle = holdElapsed - contractionTime!;
    return struggle.isNegative ? Duration.zero : struggle;
  }

  TimerState copyWith({
    TimerPhase? phase,
    Duration? holdElapsed,
    Duration? prepElapsed,
    Duration? contractionTime,
    PrepMode? prepMode,
  }) {
    return TimerState(
      phase: phase ?? this.phase,
      holdElapsed: holdElapsed ?? this.holdElapsed,
      prepElapsed: prepElapsed ?? this.prepElapsed,
      contractionTime: contractionTime ?? this.contractionTime,
      prepMode: prepMode ?? this.prepMode,
    );
  }
}
