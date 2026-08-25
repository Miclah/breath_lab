import 'dart:math';

import 'package:flutter/material.dart';

import '../../theme/colors.dart';

/// Circular progress ring for the hold timer.
///
/// [value] is the fraction of the user's personal best:
///   0.0 = no progress, 1.0 = at PB, >1.0 = past PB.
/// The arc color transitions teal → amber at 0.75, then amber → red at 1.0.
/// [child] is placed at the center (timer number + state label).
///
/// Past 1.0 the outer arc has nowhere left to go — a full circle is a full
/// circle — so beating your best by a second and doubling it rendered
/// identically. The overflow gets its own inset arc instead, which starts
/// empty at exactly PB and closes at double it.
class TimerRing extends StatelessWidget {
  const TimerRing({
    super.key,
    required this.value,
    required this.child,
    this.size,
  });

  final double value;
  final Widget child;

  /// Explicit diameter, computed by the caller from the space actually
  /// available. Falls back to a fixed mobile/desktop breakpoint size when
  /// null — used where nothing bounds the ring's parent height.
  final double? size;

  static const _mobileSize = 220.0;
  static const _desktopSize = 280.0;

  /// How much of the outer ring to sweep. Full from the PB onwards.
  static double arcFraction(double value) => value.clamp(0.0, 1.0);

  /// How much of the inset overflow arc to sweep: how far past the PB this
  /// hold is, capped at one further lap. Beyond double the PB the two arcs
  /// are both closed and stop distinguishing — by then the number in the
  /// middle is the thing being read, not the ring.
  static double overflowFraction(double value) => (value - 1.0).clamp(0.0, 1.0);

  Color _ringColor(double v, BreathLabColorScheme c) {
    if (v >= 1.0) return c.danger;
    if (v >= 0.75) {
      final t = (v - 0.75) / 0.25;
      return Color.lerp(c.primary, c.warning, t)!;
    }
    return c.primary;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final isDesktop = MediaQuery.of(context).size.width >= 600;
    final resolvedSize = size ?? (isDesktop ? _desktopSize : _mobileSize);

    return SizedBox(
      width: resolvedSize,
      height: resolvedSize,
      child: CustomPaint(
        painter: _RingPainter(
          value: value,
          ringColor: _ringColor(value, c),
          // Idle track: visible enough to read as the screen's focal shape
          // at a glance — the original 30% alpha on a near-black canvas
          // composited to almost nothing.
          trackColor: c.border.withValues(alpha: 0.55),
        ),
        child: Center(child: child),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.value,
    required this.ringColor,
    required this.trackColor,
  });

  final double value;
  final Color ringColor;
  final Color trackColor;

  static const _strokeWidth = 4.0;

  /// Clear space between the outer ring and the overflow arc.
  static const _overflowGap = 6.0;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - _strokeWidth) / 2;

    // Background track - full circle
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = _strokeWidth,
    );

    final arcPaint = Paint()
      ..color = ringColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round;

    // Foreground arc - starts at 12 o'clock, sweeps clockwise
    final clamped = TimerRing.arcFraction(value);
    if (clamped > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        clamped * 2 * pi,
        false,
        arcPaint,
      );
    }

    // Overflow arc - only past the PB, inset so it reads as a second lap
    // rather than a thicker version of the first.
    final overflow = TimerRing.overflowFraction(value);
    if (overflow > 0) {
      canvas.drawArc(
        Rect.fromCircle(
          center: center,
          radius: radius - _strokeWidth - _overflowGap,
        ),
        -pi / 2,
        overflow * 2 * pi,
        false,
        arcPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value ||
      old.ringColor != ringColor ||
      old.trackColor != trackColor;
}
