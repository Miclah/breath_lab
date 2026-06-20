import 'package:flutter/material.dart' hide Durations;
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/hold.dart';
import '../../domain/services/timer_service.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/tokens.dart';
import 'providers.dart';

/// Handles the prep phase UI for [PrepMode.threeSeconds].
/// Shows a 3 → 2 → 1 countdown with haptic ticks, then transitions to hold.
/// Returns a zero-size widget for all other prep modes or non-prep phases.
class PrepPhaseWidget extends ConsumerStatefulWidget {
  const PrepPhaseWidget({super.key});

  @override
  ConsumerState<PrepPhaseWidget> createState() => _PrepPhaseWidgetState();
}

class _PrepPhaseWidgetState extends ConsumerState<PrepPhaseWidget> {
  int _prevCountdown = -1;

  static int _remaining(Duration elapsed) =>
      (3 - elapsed.inSeconds).clamp(0, 3);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    ref.listen<TimerState>(timerProvider, (_, next) {
      if (!next.isPrep || next.prepMode != PrepMode.threeSeconds) return;
      final current = _remaining(next.prepElapsed);
      if (_prevCountdown != -1 && current < _prevCountdown) {
        HapticFeedback.lightImpact();
      }
      _prevCountdown = current;
      if (next.prepElapsed.inMilliseconds >= 3000) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) ref.read(timerProvider.notifier).beginHold();
        });
      }
    });

    final state = ref.watch(timerProvider);
    if (!state.isPrep || state.prepMode != PrepMode.threeSeconds) {
      return const SizedBox.shrink();
    }

    final elapsed = state.prepElapsed;
    final countdown = _remaining(elapsed);
    if (_prevCountdown == -1) _prevCountdown = countdown;

    final isDone = elapsed.inMilliseconds >= 3000;
    final label = isDone ? l10n.prepGoLabel : '$countdown';

    return Center(
      child: AnimatedSwitcher(
        duration: Durations.fast,
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: Text(
          label,
          key: ValueKey(label),
          style: Theme.of(
            context,
          ).textTheme.displayLarge?.copyWith(fontSize: 96),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
