import 'package:flutter/widgets.dart';

import '../../theme/tokens.dart';

/// Centers [child] and caps its width at [Layout.contentMaxWidth] — without
/// this, full-width buttons and settings rows that read fine on a phone
/// stretch edge-to-edge on a desktop window.
class ContentMaxWidth extends StatelessWidget {
  const ContentMaxWidth({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: Layout.contentMaxWidth),
        child: child,
      ),
    );
  }
}
