import 'package:flutter/material.dart' hide Durations;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/holds_repository.dart';
import '../../domain/models/hold.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/adaptive_page.dart';
import '../../shared/widgets/hold_list_item.dart';
import '../../theme/colors.dart';
import '../../theme/surfaces.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../history/history_screen.dart';
import 'calendar_heatmap.dart';
import 'progress_chart.dart';
import 'stat_card_row.dart';

const _recentHoldsCount = 10;

/// Progress tab: stat cards, calendar heatmap, trend chart, and a
/// recent-holds preview. The full filterable history lives on a screen
/// pushed from here (there is no dedicated History tab). Per PRD §7.3.
///
/// Where each piece goes depends on how much room there is. The heatmap and
/// the chart are the two things that genuinely improve with width — a
/// 12-week grid and a time series both read better wider — so they keep the
/// main column. The stat cards and the recent-holds list do not improve with
/// width at all; stretched across 900 px they are three short numbers and
/// ten mostly-empty rows. Those move sideways.
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navProgress)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Asked of the page, not the window: the navigation rail takes its
          // share first, and a screen that reads the window lays out for
          // room it does not have.
          final split = AdaptivePage.showsSide(
            constraints.maxWidth,
            maxWidth: ContentWidth.chart,
          );

          return AdaptivePage(
            maxWidth: ContentWidth.chart,
            side: split ? const _ProgressSide() : null,
            // Vertical only. The horizontal margin belongs to the page now,
            // so the two stop stacking into a 40 px inset on a phone.
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: Spacing.xl),
              children: [
                if (!split) ...[
                  const StatCardRow(),
                  const SizedBox(height: Spacing.lg),
                ],
                const CalendarHeatmap(),
                const SizedBox(height: Spacing.lg),
                const ProgressChart(),
                if (!split) ...[
                  const SizedBox(height: Spacing.xxl),
                  const RecentHoldsSection(),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProgressSide extends StatelessWidget {
  const _ProgressSide();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xl),
      children: const [
        StatCardRow(axis: Axis.vertical),
        SizedBox(height: Spacing.xxl),
        RecentHoldsSection(),
      ],
    );
  }
}

/// The last ten holds, and the way through to the full history.
///
/// Lives in the side column where there is one and in the main column where
/// there is not, so it is a widget rather than a run of list children.
class RecentHoldsSection extends ConsumerWidget {
  const RecentHoldsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final holds = ref.watch(allHoldsProvider).valueOrNull ?? const [];
    final recentHolds = holds
        .where((h) => h.type != HoldType.co2 && h.type != HoldType.o2)
        .take(_recentHoldsCount)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.progressRecentHoldsTitle.toUpperCase(),
          style: BreathLabTypography.section.copyWith(color: c.textTertiary),
        ),
        const SizedBox(height: Spacing.sm),
        // Recessed: a list nested under a heading is exactly what an inset
        // is for, and it stops the rows competing with the chart above.
        Container(
          decoration: Surfaces.inset(context),
          clipBehavior: Clip.antiAlias,
          child: recentHolds.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(Spacing.lg),
                  child: Text(
                    l10n.historyEmpty,
                    style: BreathLabTypography.micro.copyWith(
                      color: c.textTertiary,
                    ),
                  ),
                )
              : Column(
                  children: [
                    for (final (i, hold) in recentHolds.indexed) ...[
                      if (i > 0)
                        const Divider(
                          height: 1,
                          indent: Spacing.xl,
                          endIndent: Spacing.xl,
                        ),
                      HoldListItem(
                        hold: hold,
                        onTap: () => showHoldDetail(context, hold),
                      ),
                    ],
                  ],
                ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const HistoryScreen())),
            child: Text(l10n.progressViewAllHistory),
          ),
        ),
      ],
    );
  }
}
