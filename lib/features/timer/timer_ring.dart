import 'dart:math';

import 'package:flutter/material.dart';

import '../../theme/colors.dart';

/// Circular progress ring for the hold timer.
///
/// [value] is the fraction of the user's personal best:
///   0.0 = no progress, 1.0 = at PB, >1.0 = past PB.
/// The arc color transitions teal → amber at 0.75, then amber → red at 1.0.
/// [child] is placed at the center (timer number + state label).
class TimerRing extends StatelessWidget {
  const TimerRing({super.key, required this.value, required this.child});

  final double value;
  final Widget child;

  static const _mobileSize = 220.0;
  static const _desktopSize = 280.0;

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
    final size = isDesktop ? _desktopSize : _mobileSize;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          value: value,
          ringColor: _ringColor(value, c),
          trackColor: c.border.withAlpha(76),
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

  static const _strokeWidth = 3.0;

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

    // Foreground arc - starts at 12 o'clock, sweeps clockwise
    final clamped = value.clamp(0.0, 1.0);
    if (clamped > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        clamped * 2 * pi,
        false,
        Paint()
          ..color = ringColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = _strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value ||
      old.ringColor != ringColor ||
      old.trackColor != trackColor;
}
