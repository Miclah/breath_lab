import 'dart:async';

import 'package:flutter/services.dart';

import '../../data/repositories/settings_repository.dart';

enum _Pulse { weak, mid, strong }

/// Plays haptic patterns for holds and guided table sessions, per PRD §A5.
/// Every pattern is expressed as a sequence of abstract [_Pulse] levels;
/// [intensity] rescales them at fire time (off = silent, light = everything
/// weak, medium = as designed, strong = every pulse bumped up a level).
class HapticsService {
  HapticIntensity intensity = HapticIntensity.medium;

  Timer? _pastPbTicker;

  /// Max hold start: single medium pulse.
  Future<void> holdStart() => _fire([_Pulse.mid]);

  /// Max hold stop: double pulse.
  Future<void> holdStop() =>
      _fire([_Pulse.mid, _Pulse.mid], gap: const Duration(milliseconds: 150));

  /// Contraction marker: very short tick.
  Future<void> contraction() => _fire([_Pulse.weak]);

  /// Table round start (hold): triple ascending pulse.
  Future<void> tableRoundStart() =>
      _fire([_Pulse.weak, _Pulse.mid, _Pulse.strong]);

  /// Table rest 3-2-1: one short tick. Called once per remaining second.
  Future<void> tableRestCountdown() => _fire([_Pulse.weak]);

  /// Table session complete: long-short-long.
  Future<void> tableComplete() => _fire([
    _Pulse.strong,
    _Pulse.weak,
    _Pulse.strong,
  ], gap: const Duration(milliseconds: 120));

  /// PB achieved: long pulse + short staccato.
  Future<void> pbAchieved() => _fire(
    [_Pulse.strong, _Pulse.weak, _Pulse.weak, _Pulse.weak],
    gap: const Duration(milliseconds: 80),
    firstGap: const Duration(milliseconds: 200),
  );

  /// Past PB warning: insistent repeating short pulses. Call
  /// [pastPbWarningStop] to end it — it does not stop on its own.
  void pastPbWarningStart() {
    if (_pastPbTicker != null) return;
    _fire([_Pulse.weak]);
    _pastPbTicker = Timer.periodic(const Duration(milliseconds: 400), (_) {
      _fire([_Pulse.weak]);
    });
  }

  void pastPbWarningStop() {
    _pastPbTicker?.cancel();
    _pastPbTicker = null;
  }

  Future<void> _fire(
    List<_Pulse> pulses, {
    Duration gap = const Duration(milliseconds: 80),
    Duration? firstGap,
  }) async {
    if (intensity == HapticIntensity.off) return;
    for (var i = 0; i < pulses.length; i++) {
      if (i > 0) {
        await Future.delayed(i == 1 && firstGap != null ? firstGap : gap);
      }
      _resolve(pulses[i]).call();
    }
  }

  VoidCallback _resolve(_Pulse pulse) {
    final resolved = switch (intensity) {
      HapticIntensity.off => pulse, // unreachable, _fire already returned
      HapticIntensity.light => _Pulse.weak,
      HapticIntensity.medium => pulse,
      HapticIntensity.strong => switch (pulse) {
        _Pulse.weak => _Pulse.mid,
        _Pulse.mid => _Pulse.strong,
        _Pulse.strong => _Pulse.strong,
      },
    };
    return switch (resolved) {
      _Pulse.weak => HapticFeedback.lightImpact,
      _Pulse.mid => HapticFeedback.mediumImpact,
      _Pulse.strong => HapticFeedback.heavyImpact,
    };
  }
}
