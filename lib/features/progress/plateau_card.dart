import 'package:flutter/material.dart' hide Durations;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/widgets/contextual_tip.dart';
import '../../shared/widgets/hold_list_item.dart' show fmtHoldDuration;
import '../report/report_anchor.dart';
import '../../theme/colors.dart';
import '../../theme/surfaces.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import 'providers.dart';

/// The deload card, `RESEARCH_ALIGNMENT.md` §3.2. Renders nothing until the
/// last 28 days of Full-lung max holds have failed to beat the 28 before.
/// It carries the research's own advice — recovery and chest-wall stretching
/// over more volume — and never blocks training.
class PlateauCard extends ConsumerWidget {
  const PlateauCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(plateauStatusProvider);
    if (!status.plateaued) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: Surfaces.quietPanel(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_flat, size: 16, color: c.warningText),
              const SizedBox(width: Spacing.xs),
              Text(
                l10n.plateauTitle.toUpperCase(),
                style: BreathLabTypography.section.copyWith(
                  color: c.warningText,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            l10n.plateauBody(
              fmtHoldDuration(status.recentBest!),
              fmtHoldDuration(status.previousBest!),
            ),
            style: BreathLabTypography.body.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: Spacing.sm),
          ContextualTip(
            text: l10n.plateauAdvice,
            anchor: ReportAnchor.timeline,
            style: BreathLabTypography.micro.copyWith(color: c.textTertiary),
          ),
        ],
      ),
    );
  }
}
