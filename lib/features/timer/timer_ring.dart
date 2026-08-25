import 'dart:math';

import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../theme/tokens.dart';

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
    this.elapsed = Duration.zero,
    this.size,
  });

  final double value;
  final Widget child;

  /// How long this hold has actually run.
  ///
  /// [value] alone cannot say whether a warning colour is warranted: it is a
  /// ratio, and a ratio to a one-second personal best is met in one second.
  /// The colour needs the absolute time as well.
  final Duration elapsed;

  /// Explicit diameter, computed by the caller from the space actually
  /// available. Falls back to a fixed mobile/desktop breakpoint size when
  /// null — used where nothing bounds the ring's parent height.
  final double? size;

  /// Design §Layout: 220 across on a phone, 280 once there is room. Public
  /// so a caller sizing the ring from its own space has the same ceiling to
  /// clamp against, rather than a second opinion about how big it should be.
  static const compactDiameter = 220.0;
  static const expandedDiameter = 280.0;

  /// How much of the outer ring to sweep. Full from the PB onwards.
  static double arcFraction(double value) => value.clamp(0.0, 1.0);

  /// How much of the inset overflow arc to sweep: how far past the PB this
  /// hold is, capped at one further lap. Beyond double the PB the two arcs
  /// are both closed and stop distinguishing — by then the number in the
  /// middle is the thing being read, not the ring.
  static double overflowFraction(double value) => (value - 1.0).clamp(0.0, 1.0);

  /// Teal below 75% of the personal best, warming through amber to red at
  /// it — but never before the absolute floors in [RingThresholds]. Both
  /// conditions have to hold, so a small or freshly-reset best can no
  /// longer paint the ring red seconds into a hold.
  static Color ringColor(
    double value,
    Duration elapsed,
    BreathLabColorScheme c,
  ) {
    if (value >= 1.0 && elapsed >= RingThresholds.dangerFloor) return c.danger;
    if (value >= 0.75 && elapsed >= RingThresholds.warningFloor) {
      // Ratio alone drives how far through the amber ramp we are; the floor
      // decides only whether the ramp applies at all.
      final t = ((value - 0.75) / 0.25).clamp(0.0, 1.0);
      return Color.lerp(c.primary, c.warning, t)!;
    }
    return c.primary;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final isDesktop = MediaQuery.of(context).size.width >= 600;
    final resolvedSize =
        size ?? (isDesktop ? expandedDiameter : compactDiameter);

    return SizedBox(
      width: resolvedSize,
      height: resolvedSize,
      child: CustomPaint(
        painter: _RingPainter(
          value: value,
          ringColor: ringColor(value, elapsed, c),
          trackColor: c.ringTrack,
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
