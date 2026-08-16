import 'package:flutter/material.dart';

import '../../theme/colors.dart';

/// Wraps a scrollable [child] with a bottom gradient fade, signalling that
/// content continues past the visible edge — without it, a list clipped by
/// a fixed control below (e.g. Start/Stop) reads as a rendering bug rather
/// than "keep scrolling."
class BottomScrollFade extends StatelessWidget {
  const BottomScrollFade({super.key, required this.child, this.height = 32});

  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;

    return Stack(
      children: [
        child,
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: height,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [c.canvas.withValues(alpha: 0), c.canvas],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
