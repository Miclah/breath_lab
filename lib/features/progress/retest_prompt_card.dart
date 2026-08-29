import 'package:flutter/material.dart' hide Durations;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/settings_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/surfaces.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import 'providers.dart';

/// Nudges a retest of the max every 2–4 weeks (`RESEARCH_ALIGNMENT.md` §5),
/// so the CO₂/O₂ tables — which recompute from `current_max_ms` — stay based
/// on a current figure. Dismissible; renders nothing until it is due.
class RetestPromptCard extends ConsumerWidget {
  const RetestPromptCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prompt = ref.watch(retestPromptProvider).valueOrNull;
    if (prompt == null || !prompt.show) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;

    Future<void> dismiss() async {
      await ref
          .read(settingsRepositoryProvider)
          .setRetestPromptDismissedAt(DateTime.now().millisecondsSinceEpoch);
      ref.invalidate(retestPromptProvider);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        Spacing.lg,
        Spacing.lg,
        Spacing.sm,
        Spacing.lg,
      ),
      decoration: Surfaces.quietPanel(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.retestPromptTitle.toUpperCase(),
                  style: BreathLabTypography.section.copyWith(
                    color: c.textTertiary,
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                Text(
                  l10n.retestPromptBody(prompt.weeksSinceLastMax),
                  style: BreathLabTypography.body.copyWith(
                    color: c.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            tooltip: l10n.retestPromptDismiss,
            onPressed: dismiss,
          ),
        ],
      ),
    );
  }
}
