import 'package:flutter/material.dart' hide Durations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/repositories/holds_repository.dart';
import '../../data/repositories/tags_repository.dart';
import '../../data/repositories/table_sessions_repository.dart';
import '../../domain/models/hold.dart';
import '../../domain/models/table_session.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';

String _fmt(Duration d) {
  final m = d.inMinutes.toString().padLeft(2, '0');
  final s = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

String _dateLabel(DateTime dt) {
  final now = DateTime.now();
  final isToday =
      dt.year == now.year && dt.month == now.month && dt.day == now.day;
  return isToday
      ? DateFormat('HH:mm').format(dt)
      : DateFormat('d MMM').format(dt);
}

String _lungVolLabel(LungVolume v, AppLocalizations l10n) => switch (v) {
  LungVolume.full => l10n.lungVolFull,
  LungVolume.frc => l10n.lungVolFrc,
  LungVolume.empty => l10n.lungVolEmpty,
};

String tagLabel(String labelKey, AppLocalizations l10n) => switch (labelKey) {
  'tag.tired' => l10n.tagTired,
  'tag.wellRested' => l10n.tagWellRested,
  'tag.fullStomach' => l10n.tagFullStomach,
  'tag.emptyStomach' => l10n.tagEmptyStomach,
  'tag.anxious' => l10n.tagAnxious,
  'tag.greatPrep' => l10n.tagGreatPrep,
  'tag.samba' => l10n.tagSamba,
  'tag.cold' => l10n.tagCold,
  'tag.hot' => l10n.tagHot,
  String s when s.startsWith('custom:') => s.substring(7),
  _ => labelKey,
};

/// Opens the hold detail bottom sheet. Shared with the heatmap drill-down.
void showHoldDetail(BuildContext context, Hold hold) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => _HoldDetailSheet(hold: hold),
  );
}

/// A row in the merged history list: either a standalone hold or a table
/// session (table rounds are saved as individual holds too, but those are
/// represented by their session row instead, not shown separately).
sealed class _HistoryEntry {
  DateTime get createdAt;
}

class _HoldEntry extends _HistoryEntry {
  _HoldEntry(this.hold);
  final Hold hold;
  @override
  DateTime get createdAt => hold.createdAt;
}

class _TableSessionEntry extends _HistoryEntry {
  _TableSessionEntry(this.session);
  final TableSession session;
  @override
  DateTime get createdAt => session.createdAt;
}

// ---------------------------------------------------------------------------
// History screen
// ---------------------------------------------------------------------------

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final holdsAsync = ref.watch(allHoldsProvider);
    final tableSessionsAsync = ref.watch(allTableSessionsProvider);
    final holds = holdsAsync.valueOrNull;
    final tableSessions = tableSessionsAsync.valueOrNull;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.historyTitle)),
      body: holds == null || tableSessions == null
          ? holdsAsync.hasError || tableSessionsAsync.hasError
                ? const SizedBox.shrink()
                : const Center(child: CircularProgressIndicator())
          : Builder(
              builder: (context) {
                final entries = <_HistoryEntry>[
                  for (final hold in holds)
                    if (hold.type != HoldType.co2 && hold.type != HoldType.o2)
                      _HoldEntry(hold),
                  for (final session in tableSessions)
                    _TableSessionEntry(session),
                ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

                if (entries.isEmpty) {
                  return Center(
                    child: Text(
                      l10n.historyEmpty,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: entries.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, indent: Spacing.xl),
                  itemBuilder: (_, i) => switch (entries[i]) {
                    _HoldEntry(:final hold) => HoldRow(
                      hold: hold,
                      onTap: () => showHoldDetail(context, hold),
                    ),
                    _TableSessionEntry(:final session) => _TableSessionRow(
                      session: session,
                    ),
                  },
                );
              },
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// List row
// ---------------------------------------------------------------------------

/// Single hold row: duration, PB badge, lung volume, contraction dot, tag
/// dots. Shared by the history list and the Progress screen's recent
/// holds section.
class HoldRow extends ConsumerWidget {
  const HoldRow({super.key, required this.hold, required this.onTap});

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
            _fmt(hold.duration),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (hold.isPb) ...[
            const SizedBox(width: Spacing.xs),
            _PbBadge(label: l10n.historyPbBadge),
          ],
          const Spacer(),
          Text(
            _dateLabel(hold.createdAt),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: c.textTertiary),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Text(
            _lungVolLabel(hold.lungVolume, l10n),
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
              _fmt(hold.contractionTime!),
              style: TextStyle(fontSize: 12, color: c.textSecondary),
            ),
          ],
          if (tagCount > 0) ...[
            Text(
              '  ·  ',
              style: TextStyle(fontSize: 12, color: c.textTertiary),
            ),
            for (var i = 0; i < tagCount.clamp(0, 4); i++)
              Padding(
                padding: const EdgeInsets.only(right: 3),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: c.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            if (tagCount > 4)
              Text(
                '+${tagCount - 4}',
                style: TextStyle(fontSize: 10, color: c.textTertiary),
              ),
          ],
        ],
      ),
    );
  }
}

class _TableSessionRow extends StatelessWidget {
  const _TableSessionRow({required this.session});

  final TableSession session;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final avgMs = session.roundDetails.isEmpty
        ? 0
        : session.roundDetails.fold<int>(0, (sum, d) => sum + d.holdMs) ~/
              session.roundDetails.length;
    final typeLabel = switch (session.type) {
      TableType.co2 => l10n.tablesCo2Toggle,
      TableType.o2 => l10n.tablesO2Toggle,
    };

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Spacing.xl,
        vertical: Spacing.xs,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              l10n.tablesHistoryRow(
                typeLabel,
                session.roundsCompleted,
                session.roundsTotal,
                _fmt(Duration(milliseconds: avgMs)),
              ),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Text(
            _dateLabel(session.createdAt),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: c.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _PbBadge extends StatelessWidget {
  const _PbBadge({required this.label});

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

// ---------------------------------------------------------------------------
// Detail sheet
// ---------------------------------------------------------------------------

class _HoldDetailSheet extends ConsumerWidget {
  const _HoldDetailSheet({required this.hold});

  final Hold hold;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final tagsAsync = ref.watch(holdTagsProvider(hold.id));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Duration + PB
            Row(
              children: [
                Text(
                  _fmt(hold.duration),
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                if (hold.isPb) ...[
                  const SizedBox(width: Spacing.sm),
                  _PbBadge(label: l10n.historyPbBadge),
                ],
              ],
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              DateFormat('d MMM yyyy, HH:mm').format(hold.createdAt),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: c.textTertiary),
            ),
            const SizedBox(height: Spacing.lg),

            // Lung volume + contraction + struggle
            Wrap(
              spacing: Spacing.xl,
              runSpacing: Spacing.sm,
              children: [
                _DetailStat(
                  label: l10n.historyLungVolLabel,
                  value: _lungVolLabel(hold.lungVolume, l10n),
                  c: c,
                ),
                if (hold.contractionTime != null)
                  _DetailStat(
                    label: l10n.resultContraction,
                    value: _fmt(hold.contractionTime!),
                    c: c,
                  ),
                if (hold.contractionTime != null &&
                    hold.duration > hold.contractionTime!)
                  _DetailStat(
                    label: l10n.resultStruggle,
                    value: _fmt(hold.duration - hold.contractionTime!),
                    c: c,
                  ),
              ],
            ),

            // Tags
            tagsAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (error, stack) => const SizedBox.shrink(),
              data: (tags) {
                if (tags.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: Spacing.lg),
                  child: Wrap(
                    spacing: Spacing.xs,
                    runSpacing: Spacing.xs,
                    children: [
                      for (final tag in tags)
                        Chip(
                          label: Text(
                            tagLabel(tag.labelKey, l10n),
                            style: const TextStyle(fontSize: 12),
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: Spacing.lg),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.historyDetailClose),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailStat extends StatelessWidget {
  const _DetailStat({
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: c.textTertiary),
        ),
        Text(value, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}
