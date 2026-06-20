import 'package:flutter/material.dart' hide Durations;
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/hold.dart';
import '../../domain/services/timer_service.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import 'providers.dart';

/// Dispatches to the correct prep-phase UI based on [TimerState.prepMode].
/// Returns [SizedBox.shrink] when not in prep or prep mode is [PrepMode.none].
class PrepPhaseWidget extends ConsumerWidget {
  const PrepPhaseWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(timerProvider);
    if (!state.isPrep) return const SizedBox.shrink();

    return switch (state.prepMode) {
      PrepMode.threeSeconds => const _ThreeSecondCountdown(),
      PrepMode.short => const _BreathingGuide(
        totalDuration: Duration(seconds: 30),
      ),
      PrepMode.full => const _BreathingGuide(
        totalDuration: Duration(minutes: 2),
      ),
      _ => const SizedBox.shrink(),
    };
  }
}

// ---------------------------------------------------------------------------
// 3-second countdown
// ---------------------------------------------------------------------------

class _ThreeSecondCountdown extends ConsumerStatefulWidget {
  const _ThreeSecondCountdown();

  @override
  ConsumerState<_ThreeSecondCountdown> createState() =>
      _ThreeSecondCountdownState();
}

class _ThreeSecondCountdownState extends ConsumerState<_ThreeSecondCountdown> {
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

    final elapsed = ref.watch(timerProvider).prepElapsed;
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

// ---------------------------------------------------------------------------
// Breathing-circle guide (Short 30s / Full 2:00)
// ---------------------------------------------------------------------------

class _BreathingGuide extends ConsumerStatefulWidget {
  const _BreathingGuide({required this.totalDuration});

  final Duration totalDuration;

  @override
  ConsumerState<_BreathingGuide> createState() => _BreathingGuideState();
}

class _BreathingGuideState extends ConsumerState<_BreathingGuide>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  bool _prevIsInhale = true;

  // Default ratio 4s in / 6s out
  static const _inhaleSec = 4;
  static const _totalSec = 10; // 4 + 6
  static const _inhaleFraction = _inhaleSec / _totalSec; // 0.4

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(
            vsync: this,
            duration: const Duration(seconds: _totalSec),
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
    final isDesktop = MediaQuery.of(context).size.width >= 600;
    final ringSize = isDesktop ? 280.0 : 220.0;

    ref.listen<TimerState>(timerProvider, (_, next) {
      if (!next.isPrep) return;
      if (next.prepElapsed >= widget.totalDuration) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) ref.read(timerProvider.notifier).beginHold();
        });
      }
    });

    final state = ref.watch(timerProvider);
    final raw = widget.totalDuration - state.prepElapsed;
    final remaining = raw.isNegative ? Duration.zero : raw;
    final m = remaining.inMinutes;
    final s = remaining.inSeconds % 60;
    final timeLabel = '$m:${s.toString().padLeft(2, '0')}';

    final isInhale = _ctrl.value < _inhaleFraction;
    final phaseLabel = isInhale ? l10n.prepBreatheIn : l10n.prepBreatheOut;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: ringSize,
            height: ringSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _scale,
                  builder: (_, child) =>
                      Transform.scale(scale: _scale.value, child: child),
                  child: SizedBox(
                    width: ringSize,
                    height: ringSize,
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
          const SizedBox(height: Spacing.md),
          Text(
            timeLabel,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: c.textSecondary),
          ),
          TextButton(
            onPressed: () => ref.read(timerProvider.notifier).beginHold(),
            child: Text(
              l10n.prepSkip,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: c.textTertiary),
            ),
          ),
        ],
      ),
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
