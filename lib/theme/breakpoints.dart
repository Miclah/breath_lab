/// Width tiers, per Design §Layout.
///
/// The design spec draws one line, at 600 px, between "mobile" and
/// "desktop". That was enough while every screen was a single centred
/// column, but it puts a 700 px window and a 1600 px one in the same bucket,
/// and they are not the same layout problem: the first has room for a wider
/// column, the second has room for a second one. [medium] and [expanded]
/// split the desktop half along that line. The 600 px boundary itself is
/// unchanged, so nothing that already keys off it moves.
enum Breakpoint {
  /// Phone-shaped. One column, full width, page padding at its narrowest.
  compact,

  /// A small desktop window or a tablet. One column, but a wider one.
  medium,

  /// Room for a content column and something beside it.
  expanded;

  /// The tier [width] falls in. Takes a width rather than a [BuildContext]
  /// so a widget can ask about the space it was actually given, which is
  /// not the same as the size of the window.
  static Breakpoint forWidth(double width) {
    if (width < Breakpoints.medium) return Breakpoint.compact;
    if (width < Breakpoints.expanded) return Breakpoint.medium;
    return Breakpoint.expanded;
  }

  bool get isCompact => this == Breakpoint.compact;

  bool get isExpanded => this == Breakpoint.expanded;
}

/// The widths the tiers change at. Lower bound of the tier they name.
class Breakpoints {
  const Breakpoints._();

  /// Below this, a screen is a phone-shaped single column.
  static const double medium = 600;

  /// At or above this, there is room for a content column plus a side slot.
  static const double expanded = 1024;
}
