import 'package:flutter/services.dart';

/// Plays haptic patterns for guided table sessions, per PRD §A5.
class HapticsService {
  /// Table round start (hold): triple ascending pulse.
  Future<void> holdStart() async {
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 80));
    HapticFeedback.heavyImpact();
  }

  /// Table rest 3-2-1: one short tick, called once per remaining second.
  Future<void> countdownTick() async {
    HapticFeedback.lightImpact();
  }

  /// Table session complete: long-short-long.
  Future<void> sessionComplete() async {
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 120));
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 120));
    HapticFeedback.heavyImpact();
  }
}
