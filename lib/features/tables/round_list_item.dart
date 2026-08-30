import 'package:flutter/material.dart' hide Durations;

import '../../domain/services/co2_table_calculator.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/format_duration.dart';
import '../../theme/colors.dart';
import '../../theme/surfaces.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';

enum RoundItemState { upcoming, active, completed }

String formatRoundMs(int ms) => formatMmSs(Duration(milliseconds: ms));

/// Width of the hold and rest columns.
///
/// Fixed, and shared by the header and every row, because that is what makes
/// a column a column: a value has to sit under the word that names it.
const _statColumn = 56.0;

/// Width of the trailing status glyph.
const _statusColumn = 20.0;

/// The whole round list, as one card.
///
/// Design §`table-round` describes rows inside a single card separated by
/// hairlines. What was built instead was eight separate bordered cards, each
/// repeating the words "Hold" and "Rest" above its own two numbers — sixteen
/// labels for two columns. The card is the group; the rows are the members.
class RoundList extends StatelessWidget {
  const RoundList({super.key, required this.rows});

  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;

    return Container(
      // Recessed: the round list is what the summary above it describes, and
      // an inset is what nesting looks like now.
      decoration: Surfaces.inset(context),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          const _RoundListHeader(),
          for (final (i, row) in rows.indexed) ...[
            if (i > 0)
              Divider(
                height: 0.5,
                thickness: 0.5,
                color: c.border.withValues(alpha: 0.3),
              ),
            row,
          ],
        ],
      ),
    );
  }
}

class _RoundListHeader extends StatelessWidget {
  const _RoundListHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final style = BreathLabTypography.label.copyWith(color: c.textTertiary);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.lg,
        Spacing.md,
        Spacing.lg,
        Spacing.sm,
      ),
      child: Row(
        children: [
          const Spacer(),
          SizedBox(
            width: _statColumn,
            child: Text(
              l10n.tablesHoldLabel,
              textAlign: TextAlign.end,
              style: style,
            ),
          ),
          const SizedBox(width: Spacing.md),
          SizedBox(
            width: _statColumn,
            child: Text(
              l10n.tablesRestLabel,
              textAlign: TextAlign.end,
              style: style,
            ),
          ),
          const SizedBox(width: Spacing.md),
          const SizedBox(width: _statusColumn),
        ],
      ),
    );
  }
}

/// A single round row in a CO₂/O₂ table, shared by both table types.
class RoundListItem extends StatelessWidget {
  const RoundListItem({
    super.key,
    required this.number,
    required this.round,
    required this.state,
    this.elapsedMs,
    this.phaseLabel,
    this.onStopHold,
  });

  final int number;
  final TableRoundPlan round;
  final RoundItemState state;

  /// Live elapsed time within the current hold/rest phase, while active.
  final int? elapsedMs;

  /// "hold" / "rest" label shown below the live timer, while active.
  final String? phaseLabel;

  /// If set, shows a button to end the current hold early. Only meaningful
  /// during the hold phase.
  final VoidCallback? onStopHold;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final isActive = state == RoundItemState.active;

    return AnimatedContainer(
      duration: Durations.normal,
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.lg,
        vertical: Spacing.md,
      ),
      // A tint rather than a border: inside a single card, a row that draws
      // its own outline reads as a card again.
      color: isActive ? c.primarySurface : Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.tablesRoundLabel(number),
                style: BreathLabTypography.label.copyWith(
                  color: _labelColor(c),
                ),
              ),
              const Spacer(),
              _RoundStat(
                value: formatRoundMs(round.holdMs),
                c: c,
                dimmed: state != RoundItemState.completed,
              ),
              const SizedBox(width: Spacing.md),
              _RoundStat(
                value: formatRoundMs(round.restMs),
                c: c,
                dimmed: state != RoundItemState.completed,
              ),
              const SizedBox(width: Spacing.md),
              _StatusIndicator(state: state, c: c),
            ],
          ),
          if (isActive) ...[
            const SizedBox(height: Spacing.md),
            Center(
              child: Column(
                children: [
                  Text(
                    elapsedMs == null
                        ? l10n.statAbsentDuration
                        : formatRoundMs(elapsedMs!),
                    style: BreathLabTypography.displayMd.copyWith(
                      color: c.primaryText,
                    ),
                  ),
                  if (phaseLabel != null) ...[
                    const SizedBox(height: Spacing.xxs),
                    Text(
                      phaseLabel!,
                      style: BreathLabTypography.label.copyWith(
                        color: c.primaryText,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (onStopHold != null) ...[
              const SizedBox(height: Spacing.sm),
              Center(
                child: OutlinedButton(
                  onPressed: onStopHold,
                  child: Text(l10n.tablesSkipRoundButton),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Color _labelColor(BreathLabColorScheme c) => switch (state) {
    RoundItemState.upcoming => c.textTertiary,
    RoundItemState.active => c.primaryText,
    RoundItemState.completed => c.primaryText,
  };
}

class _RoundStat extends StatelessWidget {
  const _RoundStat({
    required this.value,
    required this.c,
    required this.dimmed,
  });

  final String value;
  final BreathLabColorScheme c;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _statColumn,
      child: Text(
        value,
        textAlign: TextAlign.end,
        style: BreathLabTypography.numericSm.copyWith(
          color: dimmed ? c.textTertiary : c.textPrimary,
        ),
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  const _StatusIndicator({required this.state, required this.c});

  final RoundItemState state;
  final BreathLabColorScheme c;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      RoundItemState.completed => Icon(
        Icons.check_circle,
        color: c.primary,
        size: _statusColumn,
      ),
      RoundItemState.active => Icon(
        Icons.arrow_forward,
        color: c.primary,
        size: _statusColumn,
      ),
      RoundItemState.upcoming => const SizedBox(width: _statusColumn),
    };
  }
}
