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

/// 3 cards: all-time PB, 30-day average, current streak.
class StatCardRow extends ConsumerWidget {
  const StatCardRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final pb = ref.watch(allTimePbProvider);
    final avg = ref.watch(avg30dProvider);
    final streak = ref.watch(currentStreakProvider);

    return Row(
      children: [
        StatCard(
          label: l10n.progressStatPb,
          value: pb == null ? l10n.progressStatNoData : _fmt(pb),
          valueColor: c.dangerText,
        ),
        const SizedBox(width: Spacing.md),
        StatCard(
          label: l10n.progressStatAvg30d,
          value: avg == null ? l10n.progressStatNoData : _fmt(avg),
        ),
        const SizedBox(width: Spacing.md),
        StatCard(
          label: l10n.progressStatStreak,
          value: '$streak',
          valueColor: c.primaryText,
        ),
      ],
    );
  }
}
