import 'package:flutter/material.dart' hide Durations;

import '../../domain/services/co2_table_calculator.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/surfaces.dart';
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
  const TableInfoPanel({
    super.key,
    required this.maxMs,
    required this.rounds,
    this.stacked = false,
  });

  final int maxMs;

  /// The rounds the session will actually run, so the estimate is of this
  /// table rather than of a typical one.
  final List<TableRoundPlan> rounds;

  /// True in the side column, where the panel is the only thing present and
  /// can spend vertical space; false inline, where it is a thin band above a
  /// list that needs the height more.
  final bool stacked;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;

    // The user is about to commit to roughly a quarter of an hour, and
    // nothing on the screen said so — the round list gives eight pairs of
    // times and leaves the addition to them.
    final totalMs = rounds.fold<int>(0, (sum, r) => sum + r.holdMs + r.restMs);

    final style = BreathLabTypography.body.copyWith(color: c.textSecondary);
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.tablesBasedOnMax(formatRoundMs(maxMs)), style: style),
        if (rounds.isNotEmpty) ...[
          const SizedBox(height: Spacing.xxs),
          Text(
            // Rounded up: a session that runs 14:10 is "15 minutes" of
            // your afternoon, not 14.
            l10n.tablesEstimatedDuration((totalMs / 60000).ceil()),
            style: style.copyWith(color: c.textTertiary),
          ),
        ],
      ],
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(stacked ? Spacing.lg : Spacing.md),
      decoration: Surfaces.primaryPanel(context),
      child: !stacked
          ? body
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.tablesSessionSummaryTitle.toUpperCase(),
                  style: BreathLabTypography.section.copyWith(
                    color: c.textTertiary,
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                body,
              ],
            ),
    );
  }
}
