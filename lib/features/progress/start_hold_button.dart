import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../shell/nav_provider.dart';

/// The one action that ends an empty state, per Design Revision §5.
///
/// A quiet-panel button and never a primary fill: an empty screen offering a
/// filled call to action is asking for engagement, and this app's job at that
/// moment is to explain itself, not to recruit. It also is not the only route
/// to the Timer — the tab bar always is — so it stays understated.
class StartHoldButton extends ConsumerWidget {
  const StartHoldButton({super.key});

  /// The Timer tab. First in the shell's destination list.
  static const _timerTabIndex = 0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.appColors;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: c.primaryText,
        side: BorderSide(color: c.quietBorder, width: 0.5),
        minimumSize: const Size(0, 40),
      ),
      onPressed: () =>
          ref.read(navIndexProvider.notifier).state = _timerTabIndex,
      child: Text(AppLocalizations.of(context)!.progressEmptyAction),
    );
  }
}
