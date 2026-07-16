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
import 'history_filters.dart';

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

String _prepModeLabel(PrepMode mode, AppLocalizations l10n) => switch (mode) {
  PrepMode.none => l10n.historyPrepModeNone,
  PrepMode.threeSeconds => l10n.historyPrepMode3s,
  PrepMode.short => l10n.historyPrepModeShort,
  PrepMode.full => l10n.historyPrepModeFull,
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
    final holdTagIds = ref.watch(holdTagIdsProvider).valueOrNull ?? const {};
    final types = ref.watch(historyTypeFilterProvider);
    final lungVolumes = ref.watch(historyLungVolumeFilterProvider);
    final tagFilter = ref.watch(historyTagFilterProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.historyTitle)),
      body: Column(
        children: [
          const HistoryFilterBar(),
          Expanded(
            child: holds == null || tableSessions == null
                ? holdsAsync.hasError || tableSessionsAsync.hasError
                      ? const SizedBox.shrink()
                      : const Center(child: CircularProgressIndicator())
                : Builder(
                    builder: (context) {
                      final entries = <_HistoryEntry>[
                        for (final hold in holds)
                          if (hold.type != HoldType.co2 &&
                              hold.type != HoldType.o2 &&
                              holdMatchesHistoryFilters(
                                hold,
                                types: types,
                                lungVolumes: lungVolumes,
                                tagFilter: tagFilter,
                                holdTagIds: holdTagIds[hold.id] ?? const {},
                              ))
                            _HoldEntry(hold),
                        for (final session in tableSessions)
                          if (tableSessionMatchesHistoryFilters(session, types))
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
                          _TableSessionEntry(:final session) =>
                            _TableSessionRow(session: session),
                        },
                      );
                    },
                  ),
          ),
        ],
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

class _HoldDetailSheet extends ConsumerStatefulWidget {
  const _HoldDetailSheet({required this.hold});

  final Hold hold;

  @override
  ConsumerState<_HoldDetailSheet> createState() => _HoldDetailSheetState();
}

class _HoldDetailSheetState extends ConsumerState<_HoldDetailSheet> {
  bool _editing = false;
  bool _saving = false;
  LungVolume? _editLungVolume;
  Set<String>? _editTagIds;

  Hold get _hold => widget.hold;

  void _startEdit(Set<String> currentTagIds) {
    setState(() {
      _editing = true;
      _editLungVolume = _hold.lungVolume;
      _editTagIds = Set.of(currentTagIds);
    });
  }

  void _cancelEdit() {
    setState(() {
      _editing = false;
      _editLungVolume = null;
      _editTagIds = null;
    });
  }

  Future<void> _saveEdit() async {
    if (_saving) return;
    setState(() => _saving = true);
    final holdsRepo = await ref.read(holdsRepositoryProvider.future);
    await holdsRepo.updateLungVolume(_hold.id, _editLungVolume!);
    await holdsRepo.replaceHoldTags(_hold.id, _editTagIds!.toList());
    ref.invalidate(allHoldsProvider);
    ref.invalidate(holdTagCountsProvider);
    ref.invalidate(holdTagIdsProvider);
    ref.invalidate(holdTagsProvider(_hold.id));
    if (!mounted) return;
    setState(() {
      _editing = false;
      _saving = false;
    });
  }

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.historyDeleteConfirmTitle),
        content: Text(l10n.historyDeleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.historyCancelButton),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.historyDeleteButton),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final holdsRepo = await ref.read(holdsRepositoryProvider.future);
    await holdsRepo.delete(_hold.id);
    ref.invalidate(allHoldsProvider);
    ref.invalidate(holdTagCountsProvider);
    ref.invalidate(holdTagIdsProvider);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final tagsAsync = ref.watch(holdTagsProvider(_hold.id));

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Duration + PB + edit/delete actions
            Row(
              children: [
                Text(
                  _fmt(_hold.duration),
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                if (_hold.isPb) ...[
                  const SizedBox(width: Spacing.sm),
                  _PbBadge(label: l10n.historyPbBadge),
                ],
                const Spacer(),
                if (!_editing) ...[
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: l10n.historyEditButton,
                    onPressed: () => _startEdit(
                      tagsAsync.valueOrNull?.map((t) => t.id).toSet() ??
                          const {},
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: c.danger),
                    tooltip: l10n.historyDeleteButton,
                    onPressed: _confirmDelete,
                  ),
                ],
              ],
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              DateFormat('d MMM yyyy, HH:mm').format(_hold.createdAt),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: c.textTertiary),
            ),
            const SizedBox(height: Spacing.lg),

            // Lung volume + contraction + struggle + prep mode
            Wrap(
              spacing: Spacing.xl,
              runSpacing: Spacing.sm,
              children: [
                _DetailStat(
                  label: l10n.historyLungVolLabel,
                  value: _lungVolLabel(_hold.lungVolume, l10n),
                  c: c,
                ),
                if (_hold.contractionTime != null)
                  _DetailStat(
                    label: l10n.resultContraction,
                    value: _fmt(_hold.contractionTime!),
                    c: c,
                  ),
                if (_hold.contractionTime != null &&
                    _hold.duration > _hold.contractionTime!)
                  _DetailStat(
                    label: l10n.resultStruggle,
                    value: _fmt(_hold.duration - _hold.contractionTime!),
                    c: c,
                  ),
                if (_hold.prepMode != null)
                  _DetailStat(
                    label: l10n.historyPrepModeLabel,
                    value: _prepModeLabel(_hold.prepMode!, l10n),
                    c: c,
                  ),
              ],
            ),

            if (_hold.notes != null && _hold.notes!.isNotEmpty) ...[
              const SizedBox(height: Spacing.lg),
              Text(
                l10n.historyNotesLabel,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: c.textTertiary),
              ),
              const SizedBox(height: Spacing.xxs),
              Text(_hold.notes!, style: Theme.of(context).textTheme.bodyMedium),
            ],

            const SizedBox(height: Spacing.lg),
            if (_editing)
              _EditForm(
                selectedLungVolume: _editLungVolume!,
                selectedTagIds: _editTagIds!,
                onLungVolumeChanged: (v) => setState(() => _editLungVolume = v),
                onTagToggled: (id, selected) => setState(() {
                  selected ? _editTagIds!.add(id) : _editTagIds!.remove(id);
                }),
              )
            else
              tagsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (error, stack) => const SizedBox.shrink(),
                data: (tags) {
                  if (tags.isEmpty) return const SizedBox.shrink();
                  return Wrap(
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
                  );
                },
              ),

            const SizedBox(height: Spacing.lg),
            if (_editing)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving ? null : _cancelEdit,
                      child: Text(l10n.historyCancelButton),
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: FilledButton(
                      onPressed: _saving ? null : _saveEdit,
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.resultSaveButton),
                    ),
                  ),
                ],
              )
            else
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

class _EditForm extends ConsumerWidget {
  const _EditForm({
    required this.selectedLungVolume,
    required this.selectedTagIds,
    required this.onLungVolumeChanged,
    required this.onTagToggled,
  });

  final LungVolume selectedLungVolume;
  final Set<String> selectedTagIds;
  final ValueChanged<LungVolume> onLungVolumeChanged;
  final void Function(String tagId, bool selected) onTagToggled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final tagsAsync = ref.watch(builtInTagsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.historyLungVolLabel,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: c.textTertiary),
        ),
        const SizedBox(height: Spacing.xs),
        Wrap(
          spacing: Spacing.sm,
          children: [
            for (final volume in LungVolume.values)
              ChoiceChip(
                label: Text(_lungVolLabel(volume, l10n)),
                selected: selectedLungVolume == volume,
                onSelected: (_) => onLungVolumeChanged(volume),
              ),
          ],
        ),
        const SizedBox(height: Spacing.lg),
        Text(
          l10n.historyFilterTags,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: c.textTertiary),
        ),
        const SizedBox(height: Spacing.xs),
        tagsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => const SizedBox.shrink(),
          data: (tags) => Wrap(
            spacing: Spacing.sm,
            runSpacing: Spacing.sm,
            children: [
              for (final tag in tags)
                FilterChip(
                  label: Text(tagLabel(tag.labelKey, l10n)),
                  selected: selectedTagIds.contains(tag.id),
                  onSelected: (selected) => onTagToggled(tag.id, selected),
                ),
            ],
          ),
        ),
      ],
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
