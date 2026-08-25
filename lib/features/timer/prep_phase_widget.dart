import 'dart:math' as math;

import 'package:flutter/material.dart' hide Durations;
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/settings_repository.dart';
import '../../domain/models/hold.dart';
import '../../domain/services/timer_service.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import 'providers.dart';
import 'timer_ring.dart';

/// The prep phase, split across the stage's bands rather than stacked inside
/// one of them.
///
/// [PrepPhaseWidget] is the circle and nothing else, so it fills the hero
/// band edge to edge and comes out the same diameter as the ring it stands
/// in for — concentric *and* congruent, which is what makes the transition
/// read as the ring changing rather than the screen relaying out. Its
/// labels and buttons moved to [PrepTopLabel], [PrepCountdown] and
/// [PrepActionButton], which the timer screen drops into the bands it
/// already holds open for the idle state's own chrome.
///
/// The pieces share no state. Everything they need — how far into prep we
/// are, how long prep lasts — is already in [TimerState] and settings, so
/// splitting them costs nothing but the split itself.
class PrepPhaseWidget extends ConsumerWidget {
  const PrepPhaseWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(timerProvider);
    if (!state.isPrep) return const SizedBox.shrink();

    final prepSeconds =
        ref.watch(prepBreathingDurationSecondsProvider).valueOrNull ?? 120;
    final ratio = ref.watch(breathingRatioProvider).valueOrNull ?? (4, 6);

    return switch (state.prepMode) {
      PrepMode.threeSeconds => const _ThreeSecondCircle(),
      PrepMode.short || PrepMode.full => _BreathingCircle(
        totalDuration: Duration(seconds: prepSeconds),
        inhaleSeconds: ratio.$1,
        exhaleSeconds: ratio.$2,
      ),
      _ => const SizedBox.shrink(),
    };
  }
}

/// The circle's diameter: the whole hero band, capped at the ring's own
/// ceiling so the two are the same size at every width.
double _circleDiameter(BoxConstraints constraints) {
  final ceiling = constraints.maxWidth >= TimerRing.expandedDiameter
      ? TimerRing.expandedDiameter
      : TimerRing.compactDiameter;
  return math.max(64.0, math.min(ceiling, constraints.biggest.shortestSide));
}

// ---------------------------------------------------------------------------
// Band content
// ---------------------------------------------------------------------------

/// Goes in the stage's top band during prep, where the status and preset
/// rows sit when idle.
class PrepTopLabel extends ConsumerWidget {
  const PrepTopLabel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(timerProvider);
    if (state.prepMode != PrepMode.threeSeconds) {
      return const SizedBox.shrink();
    }
    final c = context.appColors;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: Spacing.md),
        child: Text(
          AppLocalizations.of(context)!.prepGetReadyLabel,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: c.textSecondary),
        ),
      ),
    );
  }
}

/// Time left in the breathing guide, in the band the contraction badge uses
/// during a hold. The three-second countdown has its own digit inside the
/// circle and does not need saying twice.
class PrepCountdown extends ConsumerWidget {
  const PrepCountdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(timerProvider);
    if (state.prepMode == PrepMode.threeSeconds) {
      return const SizedBox.shrink();
    }
    final c = context.appColors;
    final total = Duration(
      seconds:
          ref.watch(prepBreathingDurationSecondsProvider).valueOrNull ?? 120,
    );
    final raw = total - state.prepElapsed;
    final remaining = raw.isNegative ? Duration.zero : raw;

    return Center(
      child: Text(
        '${remaining.inMinutes}:'
        '${(remaining.inSeconds % 60).toString().padLeft(2, '0')}',
        style: BreathLabTypography.statMd.copyWith(color: c.textSecondary),
      ),
    );
  }
}

/// Skip or cancel, in the band the Start and Stop buttons use.
///
/// Prep used to leave that band empty, which meant the one row the user's
/// thumb is already resting on went dead for two minutes.
class PrepActionButton extends ConsumerWidget {
  const PrepActionButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final mode = ref.watch(timerProvider).prepMode;
    final isCountdown = mode == PrepMode.threeSeconds;

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(foregroundColor: c.textSecondary),
        onPressed: isCountdown
            ? () => ref.read(timerProvider.notifier).reset()
            : () => ref.read(timerProvider.notifier).beginHold(),
        child: Text(isCountdown ? l10n.prepCancel : l10n.prepSkip),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3-second countdown
// ---------------------------------------------------------------------------

class _ThreeSecondCircle extends ConsumerStatefulWidget {
  const _ThreeSecondCircle();

  @override
  ConsumerState<_ThreeSecondCircle> createState() => _ThreeSecondCircleState();
}

class _ThreeSecondCircleState extends ConsumerState<_ThreeSecondCircle> {
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

    final c = context.appColors;
    final elapsed = ref.watch(timerProvider).prepElapsed;
    final countdown = _remaining(elapsed);
    if (_prevCountdown == -1) _prevCountdown = countdown;

    final isDone = elapsed.inMilliseconds >= 3000;
    final label = isDone ? l10n.prepGoLabel : '$countdown';

    return LayoutBuilder(
      builder: (context, constraints) {
        final diameter = _circleDiameter(constraints);
        return Center(
          child: SizedBox.square(
            dimension: diameter,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(diameter, diameter),
                  painter: _BreathCirclePainter(color: c.info),
                ),
                AnimatedSwitcher(
                  duration: Durations.fast,
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: Text(
                    label,
                    key: ValueKey(label),
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: diameter * 0.34,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Breathing circle (Short 30s / Full 2:00)
// ---------------------------------------------------------------------------

class _BreathingCircle extends ConsumerStatefulWidget {
  const _BreathingCircle({
    required this.totalDuration,
    required this.inhaleSeconds,
    required this.exhaleSeconds,
  });

  final Duration totalDuration;
  final int inhaleSeconds;
  final int exhaleSeconds;

  @override
  ConsumerState<_BreathingCircle> createState() => _BreathingCircleState();
}

class _BreathingCircleState extends ConsumerState<_BreathingCircle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final double _inhaleFraction;
  bool _prevIsInhale = true;

  @override
  void initState() {
    super.initState();
    final totalSec = widget.inhaleSeconds + widget.exhaleSeconds;
    _inhaleFraction = widget.inhaleSeconds / totalSec;
    _ctrl =
        AnimationController(
            vsync: this,
            duration: Duration(seconds: totalSec),
          )
          ..addListener(_onTick)
          ..repeat();

    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.3,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: _inhaleFraction * 100,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.3,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: (1 - _inhaleFraction) * 100,
      ),
    ]).animate(_ctrl);
  }

  void _onTick() {
    final isInhale = _ctrl.value < _inhaleFraction;
    if (isInhale != _prevIsInhale) {
      HapticFeedback.lightImpact();
      _prevIsInhale = isInhale;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;

    ref.listen<TimerState>(timerProvider, (_, next) {
      if (!next.isPrep) return;
      if (next.prepElapsed >= widget.totalDuration) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) ref.read(timerProvider.notifier).beginHold();
        });
      }
    });

    final isInhale = _ctrl.value < _inhaleFraction;
    final phaseLabel = isInhale ? l10n.prepBreatheIn : l10n.prepBreatheOut;

    return LayoutBuilder(
      builder: (context, constraints) {
        // The circle grows to 1.3 on the inhale, so its resting size is the
        // band divided by that — at full breath it exactly fills the band the
        // ring occupies.
        final box = _circleDiameter(constraints);
        final resting = box / 1.3;
        return Center(
          child: SizedBox.square(
            dimension: box,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _scale,
                  builder: (_, child) =>
                      Transform.scale(scale: _scale.value, child: child),
                  child: SizedBox.square(
                    dimension: resting,
                    child: CustomPaint(
                      painter: _BreathCirclePainter(color: c.info),
                    ),
                  ),
                ),
                AnimatedSwitcher(
                  duration: Durations.slow,
                  child: Text(
                    phaseLabel,
                    key: ValueKey(isInhale),
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: c.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BreathCirclePainter extends CustomPainter {
  const _BreathCirclePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - 3.0) / 2;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0,
    );
  }

  @override
  bool shouldRepaint(_BreathCirclePainter old) => old.color != color;
}
