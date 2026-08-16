import 'package:flutter/material.dart' hide Durations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/repositories/holds_repository.dart';
import '../../domain/models/hold.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';

String fmtHoldDuration(Duration d) {
  final m = d.inMinutes.toString().padLeft(2, '0');
  final s = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

String holdDateLabel(DateTime dt) {
  final now = DateTime.now();
  final isToday =
      dt.year == now.year && dt.month == now.month && dt.day == now.day;
  return isToday
      ? DateFormat('HH:mm').format(dt)
      : DateFormat('d MMM').format(dt);
}

String lungVolumeLabel(LungVolume v, AppLocalizations l10n) => switch (v) {
  LungVolume.full => l10n.lungVolFull,
  LungVolume.frc => l10n.lungVolFrc,
  LungVolume.empty => l10n.lungVolEmpty,
};

/// Small "PB" pill shown next to a personal-best hold's duration.
class PbBadge extends StatelessWidget {
  const PbBadge({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: c.primarySurface,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: c.primaryText,
        ),
      ),
    );
  }
}

/// Single hold row: duration, PB badge, lung volume, contraction dot, tag
/// dots. Shared by the history list, the Progress screen's recent holds
/// section, and the heatmap day drill-down sheet.
class HoldListItem extends ConsumerWidget {
  const HoldListItem({super.key, required this.hold, required this.onTap});

  final Hold hold;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final tagCount =
        ref.watch(holdTagCountsProvider).valueOrNull?[hold.id] ?? 0;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Spacing.xl,
        vertical: Spacing.xs,
      ),
      title: Row(
        children: [
          Text(
            fmtHoldDuration(hold.duration),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (hold.isPb) ...[
            const SizedBox(width: Spacing.xs),
            PbBadge(label: l10n.historyPbBadge),
          ],
          const Spacer(),
          Text(
            holdDateLabel(hold.createdAt),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: c.textTertiary),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Text(
            lungVolumeLabel(hold.lungVolume, l10n),
            style: TextStyle(fontSize: 12, color: c.textTertiary),
          ),
          if (hold.contractionTime != null) ...[
            Text(
              '  ·  ',
              style: TextStyle(fontSize: 12, color: c.textTertiary),
            ),
            Container(
              width: 5,
              height: 5,
              margin: const EdgeInsets.only(right: Spacing.xxs),
              decoration: BoxDecoration(
                color: c.primary,
                shape: BoxShape.circle,
              ),
            ),
            Text(
              fmtHoldDuration(hold.contractionTime!),
              style: TextStyle(fontSize: 12, color: c.textSecondary),
            ),
          ],
          if (tagCount > 0) ...[
            Text(
              '  ·  ',
              style: TextStyle(fontSize: 12, color: c.textTertiary),
            ),
            Text(
              l10n.historyTagCount(tagCount),
              style: TextStyle(fontSize: 12, color: c.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
