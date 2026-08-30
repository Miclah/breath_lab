import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../theme/breakpoints.dart';
import '../../theme/tokens.dart';
import 'timer_ring.dart';

/// The vertical band system the Timer screen is laid out in.
///
/// Every band that varies by state has a height that does not. The status
/// and preset rows occupy [topBandHeight] whether or not they are on
/// screen; the hero occupies a diameter derived from the page and nothing
/// else; the action button, today's holds and the contraction badge occupy
/// [reservedBelow] between them even while empty.
///
/// That is the whole trick. Before this, the ring sat in an `Expanded` that
/// absorbed the leftover height, so every row that appeared or disappeared
/// moved the ring, and the ring re-measured itself from the same shrinking
/// region and changed size too. Reserving the bands makes the hero's centre
/// arithmetic on constants and the page's own constraints — a value no
/// state transition can reach.
///
/// The result view uses the same stage, which is what puts its duration
/// number on the exact pixel the ring's centre was on.
///
/// The cost is real and deliberate: during PREP and HOLD the reserved bands
/// are empty, and that height is not given back to the ring. A ring that
/// grew whenever the screen emptied would be a ring that changes size four
/// times per hold.
class TimerStage extends StatelessWidget {
  const TimerStage({
    super.key,
    this.top,
    required this.hero,
    required this.below,
  });

  /// Band above the hero: the status and preset rows on IDLE, the PB badge
  /// and comparison line on RESULT, nothing during PREP and HOLD.
  final Widget? top;

  /// The ring, the prep circle, or the result screen's duration number.
  /// Laid out in a square of [diameterFor].
  final Widget hero;

  /// Everything under the hero, at its own height.
  ///
  /// It used to be `Expanded`, which handed it every spare pixel and pinned
  /// the action button to the bottom of the window — on a 900 px-tall window
  /// that left a third of the screen empty between the button and the holds
  /// row above it. The bands inside it are all fixed height anyway, so the
  /// slack was never doing anything except separating them.
  final Widget below;

  /// Breathing room above the top band.
  static const leadIn = Spacing.lg;

  /// Breathing room between the preset row and the hero, so the ring is not
  /// glued to the bottom of the `Standard` chip.
  static const heroGap = Spacing.lg;

  /// Status row (20) + gap (12) + preset chips (44).
  static const topBandHeight = 76.0;

  /// Height of the today's-holds band.
  static const holdsBandHeight = 44.0;

  /// Height of the contraction badge band.
  static const contractionBandHeight = 18.0;

  /// Height of the primary action button.
  static const actionBandHeight = 48.0;

  /// What the timer body always holds open below the hero.
  ///
  /// Folded into [diameterFor] so the hero is sized against the most
  /// crowded state rather than whichever one happens to be on screen. The
  /// result view passes the same constraints and so lands on the same
  /// number without having to know what the timer body contains.
  static const reservedBelow =
      Spacing.md +
      contractionBandHeight +
      Spacing.sm +
      holdsBandHeight +
      Spacing.md +
      actionBandHeight +
      Spacing.xl;

  /// Below this the ring stops being the screen's focal shape, so a very
  /// short window overflows rather than shrinking further.
  static const _minDiameter = 140.0;

  /// The hero's diameter for a page of these constraints.
  ///
  /// Depends only on the space the page was given — never on which state
  /// is being drawn.
  static double diameterFor(BoxConstraints constraints) {
    final ceiling = constraints.maxWidth >= Breakpoints.medium
        ? TimerRing.expandedDiameter
        : TimerRing.compactDiameter;
    final byHeight =
        constraints.maxHeight -
        leadIn -
        topBandHeight -
        heroGap -
        reservedBelow;
    final fitted = math.min(constraints.maxWidth, byHeight);
    return math.max(_minDiameter, math.min(ceiling, fitted));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final diameter = diameterFor(constraints);
        // Centred as one block. Every band in it has a height that does not
        // vary by state, so the block's height does not either — which is
        // what keeps the hero's centre fixed across state changes even though
        // it is now measured from the middle of the viewport rather than
        // from its top.
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: leadIn),
            SizedBox(height: topBandHeight, width: double.infinity, child: top),
            const SizedBox(height: heroGap),
            SizedBox(
              height: diameter,
              width: double.infinity,
              child: Center(
                child: SizedBox.square(dimension: diameter, child: hero),
              ),
            ),
            below,
          ],
        );
      },
    );
  }
}

/// A band of fixed height whose contents fade in and out rather than
/// pushing the layout around.
///
/// The height is the point: [AnimatedSwitcher] alone would still resize the
/// band as its child changed, and resizing anything above the hero moves
/// the hero.
class StageBand extends StatelessWidget {
  const StageBand({super.key, required this.height, this.child});

  final double height;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: AnimatedSwitcher(
        duration: Durations.normal,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
