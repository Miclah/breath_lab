import 'package:flutter/widgets.dart';

import 'colors.dart';
import 'tokens.dart';

/// The three panel roles, as decorations.
///
/// A role says what a panel is **for**, not what colour it is. Screens ask
/// for a role and get a `BoxDecoration`; they never reach for `surface` or
/// `surfaceElevated` again. That is the whole point of the indirection — the
/// old tokens were an elevation ladder, so "which grey" was a question about
/// nesting depth rather than about importance, and every card came out
/// weighing the same.
///
/// Design Revision §2 sets one rule over these:
///
/// > A screen has exactly one primary panel. Any number of quiet panels.
/// > Insets only inside something else.
///
/// "Exactly one" is a ceiling, not a quota: Timer's subject is the ring and a
/// settings form has no subject, so both correctly have none. If two things
/// on a screen both want to be primary, the screen has two subjects and the
/// fix is upstream — not a fourth role.
class Surfaces {
  const Surfaces._();

  /// Alpha of the teal hairline along a primary panel's top edge.
  static const _topEdgeAlpha = 0.30;

  static const _primaryRadius = Radius.xl;
  static const _quietRadius = Radius.lg;

  /// 12. Not a step on the shared radius scale, and it belongs to the role
  /// rather than to the scale, so it lives here.
  static const _insetRadius = 12.0;

  /// The one thing that matters on this screen.
  ///
  /// Filled, with a teal hairline along its top edge only. A border rather
  /// than a shadow or a glow, so the system's no-shadows rule holds — the
  /// edge is drawn, not simulated.
  static BoxDecoration primaryPanel(BuildContext context) {
    final c = context.appColors;
    return BoxDecoration(
      color: c.panelPrimary,
      borderRadius: BorderRadius.circular(_primaryRadius),
      border: Border(
        top: BorderSide(
          color: c.primary.withValues(alpha: _topEdgeAlpha),
          width: 0.5,
        ),
        left: BorderSide(color: c.panelBorder, width: 0.5),
        right: BorderSide(color: c.panelBorder, width: 0.5),
        bottom: BorderSide(color: c.panelBorder, width: 0.5),
      ),
    );
  }

  /// Supporting content. No fill — an outline directly on the field.
  static BoxDecoration quietPanel(BuildContext context) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(_quietRadius),
      border: Border.all(color: context.appColors.quietBorder, width: 0.5),
    );
  }

  /// Anything nested inside something else: lists, previews, keycaps.
  ///
  /// Recessed rather than elevated, which in dark mode means darker than the
  /// field it sits on.
  static BoxDecoration inset(BuildContext context) {
    final c = context.appColors;
    return BoxDecoration(
      color: c.insetFill,
      borderRadius: BorderRadius.circular(_insetRadius),
      // Design Revision §2's table names `#161E29` here, but its own summary
      // says the four fills are "the only new values in this revision" — so
      // the border comes from the existing token rather than adding a fifth.
      border: Border.all(color: c.border, width: 0.5),
    );
  }
}
