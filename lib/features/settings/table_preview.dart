import 'package:flutter/material.dart';

import '../../domain/services/co2_table_calculator.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import '../tables/round_list_item.dart' show formatRoundMs;

/// Compact read-only preview of computed table rounds, shown at the bottom
/// of the CO₂/O₂ settings sections so changes are visible immediately.
class TablePreview extends StatelessWidget {
  const TablePreview({super.key, required this.rounds});

  final List<TableRoundPlan> rounds;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.settingsTablePreviewTitle,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: Spacing.sm),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: c.border, width: 0.5),
            borderRadius: BorderRadius.circular(Radius.md),
          ),
          child: Column(
            children: [
              for (final (i, round) in rounds.indexed) ...[
                if (i > 0) Divider(height: 0.5, color: c.border),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.md,
                    vertical: Spacing.sm,
                  ),
                  child: Row(
                    children: [
                      Text(
                        l10n.tablesRoundLabel(i + 1),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const Spacer(),
                      Text(
                        '${l10n.tablesHoldLabel} ${formatRoundMs(round.holdMs)}',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: c.textSecondary),
                      ),
                      const SizedBox(width: Spacing.md),
                      Text(
                        '${l10n.tablesRestLabel} ${formatRoundMs(round.restMs)}',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: c.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
