import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../theme/breakpoints.dart';
import '../../theme/tokens.dart';

/// The container every screen wraps its body in.
///
/// It does three things and deliberately no more: it caps the content
/// column, it keeps that column off the window edge, and at
/// [Breakpoint.expanded] it puts a second column beside it. Screens stop
/// hand-rolling `Center(ConstrainedBox(...))` and stop deciding for
/// themselves what "too wide" means.
///
/// **It does not own the scroll.** Callers pass their own `ListView` or
/// `SingleChildScrollView`, and get back a box with the same height they
/// had before — so an `Expanded` inside the child keeps working. A
/// container that wrapped its child in a scroll view would break every
/// screen that fills its height, and would quietly add a second scrollbar
/// to every screen that already scrolls.
///
/// **It measures itself, not the window.** Every screen sits inside the
/// shell's navigation rail, so the window is always wider than the page. A
/// page that asked [MediaQuery] would lay out for room it does not have.
class AdaptivePage extends StatelessWidget {
  const AdaptivePage({
    super.key,
    required this.child,
    this.maxWidth = ContentWidth.reading,
    this.side,
    this.padding,
    this.reserveSide = false,
    this.centerVertically = false,
  });

  /// The page body. Receives a full-height box, so a `ListView` or an
  /// `Expanded` inside it behaves exactly as it would unwrapped.
  final Widget child;

  /// Cap on the content column. Pass a [ContentWidth] token, never a
  /// literal — the token is what says which kind of column this is.
  final double maxWidth;

  /// Supplementary content shown beside [child] when there is room.
  ///
  /// Not built at all below [Breakpoint.expanded], or when the two columns
  /// would not fit. Never put something the user must be able to reach
  /// here — on a phone it does not exist.
  final Widget? side;

  /// Space between the page edge and the content. Null means the
  /// per-breakpoint token. Pass [EdgeInsets.zero] when the child already
  /// pads itself, or the two will stack.
  final EdgeInsetsGeometry? padding;

  /// Hold the side column's width open even while [side] is null.
  ///
  /// Without this the page centres one column when there is no side content
  /// and centres content-plus-side when there is, so a screen that shows a
  /// side panel in some of its states and not others slides its main column
  /// sideways by half the side width plus half the gap — 176 px — every
  /// time it changes state. The timer screen does exactly that, and it is
  /// the reason the ring appeared to jump.
  ///
  /// With it, the main column's left edge depends on the page width alone.
  /// A screen whose side content comes and goes should always set it.
  final bool reserveSide;

  /// Give the content column a scroll view that only scrolls when it has
  /// to, and centre the content inside it when it does not.
  ///
  /// Design Revision §4: a screen shorter than its viewport centres
  /// vertically rather than top-anchoring with the action button pinned to
  /// the window bottom — that pairing is what read as abandonment rather
  /// than breathing room, and it is why the old build put its content in the
  /// top 41 % of a tall window.
  ///
  /// Only for screens whose content is a fixed block. A screen that already
  /// passes its own `ListView` must leave this false, or it nests one
  /// scrollable inside another.
  final bool centerVertically;

  /// Wraps [child] so it can overflow into a scroll instead of an error.
  ///
  /// `minHeight` is what does the centring: it forces the child to at least
  /// the viewport's height, so a `Column` inside it with
  /// `MainAxisAlignment.center` has room to distribute. Taller content
  /// exceeds the minimum, the scroll view takes over, and it top-anchors —
  /// which is the behaviour the revision keeps for overflow.
  Widget _fitted(Widget content) {
    if (!centerVertically) return content;
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: content,
        ),
      ),
    );
  }

  /// Whether a page capped at [maxWidth] gets a side column in [width], at
  /// the default padding.
  ///
  /// Exposed so a screen can decide what to put where without re-deriving
  /// the fit rule and drifting out of step with the rule the page actually
  /// applies.
  static bool showsSide(double width, {required double maxWidth}) {
    final breakpoint = Breakpoint.forWidth(width);
    final available = math.max(
      0.0,
      width - PagePadding.horizontal(breakpoint) * 2,
    );
    return breakpoint.isExpanded && _sideFits(available, maxWidth);
  }

  static bool _sideFits(double available, double maxWidth) =>
      available >= maxWidth + PagePadding.columnGap + ContentWidth.sideMin;

  /// The narrowest composition that fits two columns at their minimums.
  static const _narrowestTwoColumn =
      ContentWidth.reading + PagePadding.columnGap + ContentWidth.sideMin;

  /// How wide the side column is inside a composition of [composition] px.
  ///
  /// Interpolated across the range the composition itself grows over, so it
  /// sits at [ContentWidth.sideMin] the moment two columns first fit and at
  /// [ContentWidth.sideMax] once the composition reaches its cap.
  static double sideWidthFor(double composition) {
    final t =
        ((composition - _narrowestTwoColumn) /
                (ContentWidth.composition - _narrowestTwoColumn))
            .clamp(0.0, 1.0);
    return ContentWidth.sideMin +
        (ContentWidth.sideMax - ContentWidth.sideMin) * t;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final breakpoint = Breakpoint.forWidth(width);
        final resolvedPadding =
            padding ??
            EdgeInsets.symmetric(
              horizontal: PagePadding.horizontal(breakpoint),
            );

        // Padding is taken out of the width the columns get to share rather
        // than wrapped around them, so it only bites when the window is
        // narrower than the cap — which is the one case it exists for.
        final available = math.max(0.0, width - resolvedPadding.horizontal);

        // Design Revision §4: the composition caps, and past the cap the
        // surplus is margin rather than column width. Without this a 2560 px
        // window either stretched one column across the whole canvas or left
        // most of it dead — the two failure modes the revision names.
        final composition = math.min(available, ContentWidth.composition);

        final twoColumn =
            (side != null || reserveSide) &&
            breakpoint.isExpanded &&
            _sideFits(available, maxWidth);

        if (!twoColumn) {
          return Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: math.min(maxWidth, composition),
              child: _fitted(child),
            ),
          );
        }

        // Both columns are fluid, and [maxWidth] is the ceiling on the
        // content one rather than its fixed width — which is what lets a
        // screen grow from 600 towards 900 with the window while Settings
        // and Tables stay at the narrower caps Design §Layout gives them.
        final sideWidth = sideWidthFor(composition);
        final contentWidth = math.min(
          maxWidth,
          composition - PagePadding.columnGap - sideWidth,
        );

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(width: contentWidth, child: _fitted(child)),
            const SizedBox(width: PagePadding.columnGap),
            // Null child on purpose under [reserveSide]: the box still
            // occupies its width and paints nothing, which is the whole
            // point — the geometry must not know whether the slot is full.
            SizedBox(width: sideWidth, child: side),
          ],
        );
      },
    );
  }
}
