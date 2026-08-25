import 'package:flutter/material.dart';

import '../../domain/services/co2_table_calculator.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import '../tables/round_list_item.dart' show formatRoundMs;

/// Compact read-only preview of computed table rounds, shown at the bottom
/// of the CO₂/O₂ settings sections so changes are visible immediately.
///
/// Collapsed by default. Two of these expanded put fifteen or sixteen rows
/// of read-only numbers in the middle of the settings form, between the
/// controls above them and every section below — which is a long way to
/// scroll past something the user is not editing. Open, it is exactly as
/// useful as it was; closed, the sliders it belongs to are still on screen
/// together.
class TablePreview extends StatefulWidget {
  const TablePreview({super.key, required this.rounds});

  final List<TableRoundPlan> rounds;

  @override
  State<TablePreview> createState() => _TablePreviewState();
}

class _TablePreviewState extends State<TablePreview> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final rounds = widget.rounds;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(Radius.sm),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
            child: Row(
              children: [
                Text(
                  l10n.settingsTablePreviewTitle,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(width: Spacing.xs),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.expand_more,
                    size: 18,
                    color: c.textTertiary,
                  ),
                ),
                const Spacer(),
                if (!_expanded)
                  Text(
                    l10n.settingsTablePreviewRoundCount(rounds.length),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: c.textTertiary),
                  ),
              ],
            ),
          ),
        ),
        if (!_expanded)
          const SizedBox.shrink()
        else ...[
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
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: c.textSecondary),
                        ),
                        const SizedBox(width: Spacing.md),
                        Text(
                          '${l10n.tablesRestLabel} ${formatRoundMs(round.restMs)}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: c.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}
