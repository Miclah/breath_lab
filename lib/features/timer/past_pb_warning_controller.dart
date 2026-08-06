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

  void _sync() {
    final state = ref.read(timerProvider);
    final maxMs = ref.read(currentMaxMsProvider).valueOrNull;

    final shouldWarn =
        state.isHolding &&
        maxMs != null &&
        maxMs > 0 &&
        state.holdElapsed.inMilliseconds > maxMs;

    if (shouldWarn == _isWarning) return;
    _isWarning = shouldWarn;
    final service = ref.read(hapticsServiceProvider);
    if (shouldWarn) {
      service.pastPbWarningStart();
    } else {
      service.pastPbWarningStop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listened to rather than watched: starting and stopping the haptic
    // is a side effect, and firing it from inside build runs it during the
    // build phase on every 50ms tick.
    ref.listen(timerProvider, (_, _) => _sync());
    ref.listen(currentMaxMsProvider, (_, _) => _sync());

    return const SizedBox.shrink();
  }
}
