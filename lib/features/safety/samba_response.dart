import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'safety_screen.dart';

/// The tag key for a samba / loss of motor control.
const sambaTagKey = 'tag.samba';

/// Shown when the user marks a samba on a hold. Loss of motor control is a
/// near-blackout indicator (`RESEARCH_ALIGNMENT.md` §4 S3), so the tag is not
/// an inert dot: it says stop for the day and offers the safety screen.
Future<void> showSambaSafetyResponse(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: Icon(
        Icons.warning_amber_rounded,
        color: Theme.of(dialogContext).colorScheme.error,
      ),
      title: Text(l10n.sambaResponseTitle),
      content: Text(l10n.sambaResponseBody),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(dialogContext).pop();
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SafetyScreen()),
            );
          },
          child: Text(l10n.sambaResponseSafety),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(l10n.sambaResponseAcknowledge),
        ),
      ],
    ),
  );
}
