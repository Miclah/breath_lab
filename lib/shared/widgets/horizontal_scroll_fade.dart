import 'package:flutter/material.dart';

import '../../theme/colors.dart';

/// Wraps a horizontally scrollable [child] with fades at both edges,
/// signalling that content continues past the visible edge — without it, a
/// chip row cut flush by the screen edge reads like a rendering bug rather
/// than "swipe for more."
class HorizontalScrollFade extends StatelessWidget {
  const HorizontalScrollFade({
    super.key,
    required this.child,
    this.width = 24,
    this.color,
  });

  final Widget child;
  final double width;

  /// What the fade resolves to at the edge. Defaults to the canvas, which is
  /// right for a row sitting directly on the page and wrong for one inside a
  /// card — there the fade has to match the card, or it paints a pale bar
  /// over it.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final base = color ?? context.appColors.canvas;

    Widget edge(Alignment begin, Alignment end) => DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: begin,
          end: end,
          colors: [base, base.withValues(alpha: 0)],
        ),
      ),
    );

    return Stack(
      children: [
        child,
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: width,
          child: IgnorePointer(
            child: edge(Alignment.centerLeft, Alignment.centerRight),
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          width: width,
          child: IgnorePointer(
            child: edge(Alignment.centerRight, Alignment.centerLeft),
          ),
        ),
      ],
    );
  }
}
