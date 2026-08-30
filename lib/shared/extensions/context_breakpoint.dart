import 'package:flutter/widgets.dart';

import '../../theme/breakpoints.dart';

extension BreakpointContext on BuildContext {
  /// The tier of the **window**, not of the space this widget was given.
  ///
  /// Right for decisions about the app's overall shape — the shell choosing
  /// a bottom bar or a side rail, a ring picking its diameter. Wrong for
  /// deciding how many columns a page body gets: every screen sits inside
  /// the shell's rail, so the window is always wider than the page, and a
  /// page that asked the window would claim room it does not have. Size
  /// those from the constraints a `LayoutBuilder` hands you instead.
  Breakpoint get breakpoint =>
      Breakpoint.forWidth(MediaQuery.sizeOf(this).width);
}
