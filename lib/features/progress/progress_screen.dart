import 'package:flutter/material.dart' hide Durations;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/holds_repository.dart';
import '../../domain/models/hold.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/content_max_width.dart';
import '../../shared/widgets/hold_list_item.dart';
import '../../theme/colors.dart';
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
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final holds = ref.watch(allHoldsProvider).valueOrNull ?? const [];
    final recentHolds = holds
        .where((h) => h.type != HoldType.co2 && h.type != HoldType.o2)
        .take(_recentHoldsCount)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navProgress)),
      body: ContentMaxWidth(
        child: ListView(
          padding: const EdgeInsets.all(Spacing.xl),
          children: [
            const StatCardRow(),
            const SizedBox(height: Spacing.lg),
            const CalendarHeatmap(),
            const SizedBox(height: Spacing.lg),
            const ProgressChart(),
            const SizedBox(height: Spacing.xxl),
            Text(
              l10n.progressRecentHoldsTitle,
              style: BreathLabTypography.headingSm.copyWith(
                color: c.textPrimary,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            if (recentHolds.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: Spacing.lg),
                child: Text(
                  l10n.historyEmpty,
                  style: BreathLabTypography.bodySm.copyWith(
                    color: c.textTertiary,
                  ),
                ),
              )
            else
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
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                ),
                child: Text(l10n.progressViewAllHistory),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
