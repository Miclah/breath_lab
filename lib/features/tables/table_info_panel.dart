import 'package:flutter/material.dart' hide Durations;

import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import 'round_list_item.dart';

/// What the session about to be run is built from.
///
/// One widget, two placements: a card above the round list where the page is
/// one column, and the side column's whole content where there are two.
/// Duplicating it into both would tell the user the same fact twice, so the
/// screen picks one.
///
/// Phase 3C adds the evidence tier and the Declercq/Bouten tip here — the
/// panel exists partly so those have somewhere to land that is not on top of
/// the round list.
class TableInfoPanel extends StatelessWidget {
  const TableInfoPanel({super.key, required this.maxMs, this.stacked = false});

  final int maxMs;

  /// True in the side column, where the panel is the only thing present and
  /// can spend vertical space; false inline, where it is a thin band above a
  /// list that needs the height more.
  final bool stacked;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;

    final body = Text(
      l10n.tablesBasedOnMax(formatRoundMs(maxMs)),
      style: BreathLabTypography.bodySm.copyWith(color: c.textSecondary),
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(stacked ? Spacing.lg : Spacing.md),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(stacked ? Radius.xl : Radius.md),
      ),
      child: !stacked
          ? body
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.tablesSessionSummaryTitle.toUpperCase(),
                  style: BreathLabTypography.caption.copyWith(
                    color: c.textTertiary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                body,
              ],
            ),
    );
  }
}
