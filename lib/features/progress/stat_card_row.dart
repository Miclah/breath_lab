import 'package:flutter/material.dart' hide Durations;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import 'providers.dart';
import 'stat_card.dart';

String _fmt(Duration d) {
  final m = d.inMinutes.toString().padLeft(2, '0');
  final s = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

/// 3 cards: all-time PB, 30-day average, weeks trained.
///
/// Each carries its own colour, per Design §`stat-card`: the record stands
/// apart, the weeks figure is teal, and the average is plain text because an
/// average is not an achievement. Weeks trained is the demoted streak
/// (`RESEARCH_ALIGNMENT.md` §3.1) — this week's adherence is the headline,
/// on the Timer screen.
///
/// Stacks instead of sitting three-up when it moves into the side column,
/// where 320 px across three cards would leave each too narrow to hold a
/// `mm:ss` in stat-hero type.
class StatCardRow extends ConsumerWidget {
  const StatCardRow({super.key, this.axis = Axis.horizontal});

  final Axis axis;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final pb = ref.watch(allTimePbProvider);
    final avg = ref.watch(avg30dProvider);
    final weeks = ref.watch(trainingWeeksProvider);

    // An absent value keeps the row's rhythm but not its accent: gold on
    // `\u2014\u2014:\u2014\u2014` would be colour-coding a record that does not exist.
    final cards = [
      StatCard(
        label: l10n.progressStatPb,
        value: pb == null ? l10n.statAbsentDuration : _fmt(pb),
        valueColor: pb == null ? c.textTertiary : c.recordText,
      ),
      StatCard(
        label: l10n.progressStatAvg30d,
        value: avg == null ? l10n.statAbsentDuration : _fmt(avg),
        valueColor: avg == null ? c.textTertiary : null,
      ),
      StatCard(
        label: l10n.progressStatWeeksTrained,
        // Zero and none are the same thing to a reader here, and none is the
        // honest one on a fresh install.
        value: weeks == 0 ? l10n.statAbsentCount : '$weeks',
        valueColor: weeks == 0 ? c.textTertiary : c.primaryText,
      ),
    ];

    // Hairlines rather than gaps between boxes. Bare on the field, a rule is
    // the only thing saying where one stat ends and the next begins.
    Widget stacked() => Column(
      children: [
        for (final (i, card) in cards.indexed) ...[
          if (i > 0) Divider(height: 1, thickness: 1, color: c.border),
          card,
        ],
      ],
    );

    if (axis == Axis.vertical) return stacked();

    // Three-up needs room for a `mm:ss` in stat-hero type per card. Below
    // that the row stacks rather than letting the value wrap mid-digit —
    // `03:30` breaking to `03:3` / `0` at 400 px.
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 480) return stacked();
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, card) in cards.indexed) ...[
                if (i > 0)
                  VerticalDivider(
                    width: Spacing.xl,
                    thickness: 1,
                    color: c.border,
                  ),
                Expanded(child: card),
              ],
            ],
          ),
        );
      },
    );
  }
}
