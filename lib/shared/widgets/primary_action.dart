import 'package:flutter/widgets.dart';

import '../../theme/breakpoints.dart';
import '../../theme/tokens.dart';

/// Sizes a screen's primary action button.
///
/// Full-width is a phone rule that followed the layout onto the desktop and
/// produced 600 px-wide slabs — a Start button as wide as the content column
/// reads as a banner, not as something to press. Design Revision §4 caps it
/// at [ContentWidth.action] and centres it once there is room; on compact it
/// stays full-width, which is right there.
///
/// The 48 px minimum height is unchanged, and is the button's own business
/// rather than this widget's.
class PrimaryAction extends StatelessWidget {
  const PrimaryAction({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Measured from the column it is in, not the window: the button lives
        // inside the content column, and that is the width it has to look
        // right against.
        final expanded = !Breakpoint.forWidth(constraints.maxWidth).isCompact;
        if (!expanded) {
          return SizedBox(width: double.infinity, child: child);
        }
        return Center(
          child: SizedBox(width: ContentWidth.action, child: child),
        );
      },
    );
  }
}
