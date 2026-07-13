import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/table_sessions_repository.dart';
import '../../domain/models/table_session.dart';
import '../../domain/services/table_session_state.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import 'round_list_item.dart';

/// Shown once a table session ends (naturally or via early stop): rounds
/// completed, total/average hold time, and a comparison to the previous
/// same-type session.
class SessionSummaryView extends ConsumerWidget {
  const SessionSummaryView({super.key, required this.session});

  final TableSessionState session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;

    final completed = session.completedRounds.where((d) => d.completed).length;
    final total = session.rounds.length;
    final totalHoldMs = session.completedRounds.fold<int>(
      0,
      (sum, d) => sum + d.holdMs,
    );
    final avgHoldMs = session.completedRounds.isEmpty
        ? 0
        : totalHoldMs ~/ session.completedRounds.length;

    final sameTypeSessions =
        ref
            .watch(allTableSessionsProvider)
            .valueOrNull
            ?.where((s) => s.type == session.type && s.id != session.sessionId)
            .toList() ??
        const [];
    final previousDetails = sameTypeSessions.isEmpty
        ? const <TableRoundDetail>[]
        : sameTypeSessions.first.roundDetails;
    final previousAvgHoldMs = previousDetails.isEmpty
        ? null
        : previousDetails.fold<int>(0, (sum, d) => sum + d.holdMs) ~/
              previousDetails.length;

    return ListView(
      padding: const EdgeInsets.all(Spacing.lg),
      children: [
        Text(
          l10n.tablesSummaryTitle,
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Spacing.xl),
        Text(
          l10n.tablesSummaryRounds(completed, total),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: c.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Spacing.xl),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SummaryStat(
              label: l10n.tablesSummaryTotalHold,
              value: formatRoundMs(totalHoldMs),
              c: c,
            ),
            const SizedBox(width: Spacing.xxl),
            _SummaryStat(
              label: l10n.tablesSummaryAverageHold,
              value: formatRoundMs(avgHoldMs),
              c: c,
            ),
          ],
        ),
        const SizedBox(height: Spacing.xl),
        Text(
          previousAvgHoldMs == null
              ? l10n.tablesSummaryNoPrevious
              : l10n.tablesSummaryVsPrevious(
                  _formatDelta(avgHoldMs - previousAvgHoldMs),
                ),
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: c.textTertiary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

String _formatDelta(int deltaMs) {
  final sign = deltaMs >= 0 ? '+' : '-';
  return '$sign${formatRoundMs(deltaMs.abs())}';
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.label,
    required this.value,
    required this.c,
  });

  final String label;
  final String value;
  final BreathLabColorScheme c;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: BreathLabTypography.label.copyWith(color: c.textTertiary),
        ),
        const SizedBox(height: Spacing.xxs),
        Text(
          value,
          style: BreathLabTypography.statHero.copyWith(color: c.textPrimary),
        ),
      ],
    );
  }
}
