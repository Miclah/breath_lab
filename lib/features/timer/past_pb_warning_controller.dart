import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/settings_repository.dart';
import '../tables/providers.dart' show hapticsServiceProvider;
import 'providers.dart';

/// Invisible widget that fires the repeating past-PB haptic warning once
/// the current max hold's elapsed time passes the all-time PB, and stops it
/// when the hold ends. Mount once in the Timer screen's widget tree —
/// renders nothing.
class PastPbWarningController extends ConsumerStatefulWidget {
  const PastPbWarningController({super.key});

  @override
  ConsumerState<PastPbWarningController> createState() =>
      _PastPbWarningControllerState();
}

class _PastPbWarningControllerState
    extends ConsumerState<PastPbWarningController> {
  bool _isWarning = false;

  @override
  void dispose() {
    if (_isWarning) ref.read(hapticsServiceProvider).pastPbWarningStop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(timerProvider);
    final maxMs = ref.watch(currentMaxMsProvider).valueOrNull;

    final shouldWarn =
        state.isHolding &&
        maxMs != null &&
        maxMs > 0 &&
        state.holdElapsed.inMilliseconds > maxMs;

    if (shouldWarn != _isWarning) {
      _isWarning = shouldWarn;
      final service = ref.read(hapticsServiceProvider);
      if (shouldWarn) {
        service.pastPbWarningStart();
      } else {
        service.pastPbWarningStop();
      }
    }

    return const SizedBox.shrink();
  }
}
