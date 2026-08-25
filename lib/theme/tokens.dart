import 'breakpoints.dart';

class Spacing {
  const Spacing._();

  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double xxxxl = 48;
}

class Radius {
  const Radius._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 10;
  static const double lg = 14;
  static const double xl = 16;
  static const double pill = 9999;
}

class Durations {
  const Durations._();

  static const Duration fast = Duration(milliseconds: 100);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 300);
}

class Layout {
  const Layout._();

  /// Cap on tab content width. Unconstrained, full-width buttons and
  /// settings rows that read fine on a phone stretch edge-to-edge on a
  /// desktop window and become unreadable.
  ///
  /// Superseded by [ContentWidth], which says *which kind* of column is
  /// being capped instead of applying one number to all of them.
  // TODO(phase-3a): remove along with ContentMaxWidth once every screen is
  // on AdaptivePage.
  static const double contentMaxWidth = 600;
}

/// How wide a column is allowed to get, by what it holds.
///
/// These replace the bare `maxWidth:` numbers that were scattered across
/// screens. A token names the *intent*, so two of them sharing a value today
/// can still diverge later without hunting down which 600 meant what.
/// Values from Design §Layout.
class ContentWidth {
  const ContentWidth._();

  /// A list of rows the user reads and taps through: Settings.
  static const double form = 520;

  /// Prose and mixed content. The default, and the widest a single column
  /// of text should get before the eye starts losing the line.
  static const double reading = 600;

  /// Charts, which need width to be legible but stop gaining from it.
  static const double chart = 600;

  /// Short, scannable rows: the CO2/O2 table round list.
  static const double list = 480;

  /// Content that genuinely uses the room — a multi-column body.
  static const double wide = 900;

  /// The supplementary column beside the content at [Breakpoint.expanded].
  static const double side = 320;
}

/// Padding tokens that depend on how much room there is.
class PagePadding {
  const PagePadding._();

  /// Horizontal padding between the page edge and its content.
  /// 20 on a phone, 32 once there is room for it — Design §Layout.
  static double horizontal(Breakpoint breakpoint) =>
      breakpoint.isCompact ? Spacing.xl : Spacing.xxxl;

  /// The gap between the content column and a side slot.
  static const double columnGap = Spacing.xxxl;
}
