import 'package:flutter/material.dart' hide Durations;

import '../../domain/services/co2_table_calculator.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';

enum RoundItemState { upcoming, active, completed }

String formatRoundMs(int ms) {
  final d = Duration(milliseconds: ms);
  final m = d.inMinutes.toString().padLeft(2, '0');
  final s = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

/// A single round row in a CO₂/O₂ table, shared by both table types.
class RoundListItem extends StatelessWidget {
  const RoundListItem({
    super.key,
    required this.number,
    required this.round,
    required this.state,
  });

  final int number;
  final TableRoundPlan round;
  final RoundItemState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;

    return AnimatedContainer(
      duration: Durations.normal,
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.lg,
        vertical: Spacing.md,
      ),
      decoration: BoxDecoration(
        color: state == RoundItemState.active ? c.warningSurface : c.surface,
        border: Border.all(
          color: state == RoundItemState.active ? c.warning : c.border,
        ),
        borderRadius: BorderRadius.circular(Radius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.tablesRoundLabel(number),
                style: BreathLabTypography.bodySm.copyWith(
                  color: _labelColor(c),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              _RoundStat(
                label: l10n.tablesHoldLabel,
                value: formatRoundMs(round.holdMs),
                c: c,
                dimmed: state == RoundItemState.upcoming,
              ),
              const SizedBox(width: Spacing.xl),
              _RoundStat(
                label: l10n.tablesRestLabel,
                value: formatRoundMs(round.restMs),
                c: c,
                dimmed: state == RoundItemState.upcoming,
              ),
              const SizedBox(width: Spacing.md),
              _StatusIndicator(state: state, c: c),
            ],
          ),
          if (state == RoundItemState.active) ...[
            const SizedBox(height: Spacing.md),
            Center(
              child: Text(
                '--:--',
                style: BreathLabTypography.timerDisplay.copyWith(
                  color: c.warningText,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _labelColor(BreathLabColorScheme c) => switch (state) {
    RoundItemState.upcoming => c.textTertiary,
    RoundItemState.active => c.warningText,
    RoundItemState.completed => c.primaryText,
  };
}

class _RoundStat extends StatelessWidget {
  const _RoundStat({
    required this.label,
    required this.value,
    required this.c,
    required this.dimmed,
  });

  final String label;
  final String value;
  final BreathLabColorScheme c;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: BreathLabTypography.label.copyWith(color: c.textTertiary),
        ),
        Text(
          value,
          style: BreathLabTypography.statSm.copyWith(
            color: dimmed ? c.textTertiary : c.textPrimary,
          ),
        ),
      ],
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
        size: 20,
      ),
      RoundItemState.active => Icon(
        Icons.arrow_forward,
        color: c.warning,
        size: 20,
      ),
      RoundItemState.upcoming => const SizedBox(width: 20),
    };
  }
}
