import 'package:flutter/material.dart' hide Durations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/repositories/holds_repository.dart';
import '../../data/repositories/imst_sessions_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/tags_repository.dart';
import '../../data/repositories/table_sessions_repository.dart';
import '../../domain/models/hold.dart';
import '../../domain/models/imst_session.dart';
import '../../domain/models/table_session.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/hold_list_item.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import 'history_filters.dart';
import '../../theme/surfaces.dart';

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

class _ImstEntry extends _HistoryEntry {
  _ImstEntry(this.session);
  final ImstSession session;
  @override
  DateTime get createdAt => session.createdAt;
}

/// Opens the read-only IMST session detail sheet.
void showImstDetail(BuildContext context, ImstSession session) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => _ImstDetailSheet(session: session),
  );
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
    final imstSessions =
        ref.watch(allImstSessionsProvider).valueOrNull ?? const [];
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
                        for (final session in imstSessions)
                          if (imstMatchesHistoryFilters(types))
                            _ImstEntry(session),
                      ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

                      if (entries.isEmpty) {
                        return Center(
                          child: Text(
                            l10n.historyEmpty,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        );
                      }
                      // Recessed: the list is nested under the filter bar
                      // that scopes it, and an inset is what nesting looks
                      // like now.
                      return Container(
                        margin: const EdgeInsets.fromLTRB(
                          Spacing.xl,
                          0,
                          Spacing.xl,
                          Spacing.xl,
                        ),
                        decoration: Surfaces.inset(context),
                        clipBehavior: Clip.antiAlias,
                        child: ListView.separated(
                          itemCount: entries.length,
                          separatorBuilder: (context, index) => const Divider(
                            height: 1,
                            indent: Spacing.xl,
                            endIndent: Spacing.xl,
                          ),
                          itemBuilder: (_, i) => switch (entries[i]) {
                            _HoldEntry(:final hold) => HoldListItem(
                              hold: hold,
                              onTap: () => showHoldDetail(context, hold),
                            ),
                            _TableSessionEntry(:final session) =>
                              _TableSessionRow(session: session),
                            _ImstEntry(:final session) => _ImstSessionRow(
                              session: session,
                              onTap: () => showImstDetail(context, session),
                            ),
                          },
                        ),
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
                fmtHoldDuration(Duration(milliseconds: avgMs)),
              ),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Text(
            holdDateLabel(session.createdAt),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: c.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _ImstSessionRow extends StatelessWidget {
  const _ImstSessionRow({required this.session, required this.onTap});

  final ImstSession session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Spacing.xl,
        vertical: Spacing.xs,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              session.deviceLevel == null
                  ? l10n.imstDayRow(session.breaths)
                  : l10n.imstHistoryRow(session.breaths, session.deviceLevel!),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Text(
            holdDateLabel(session.createdAt),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: c.textTertiary),
          ),
        ],
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
    final bestMs = await holdsRepo.delete(_hold.id);
    // Deleting the record holder moves the PB flag to whatever is now
    // longest; the current max has to follow, or the CO2/O2 tables keep
    // computing their rounds from a hold that no longer exists.
    // TODO(phase-3b): clear the current max when the last max hold is deleted
    // — delete() returns null both for that case and for a non-max hold.
    if (bestMs != null) {
      await ref.read(currentMaxMsProvider.notifier).set(bestMs);
    }
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
                  fmtHoldDuration(_hold.duration),
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                if (_hold.isPb) ...[
                  const SizedBox(width: Spacing.sm),
                  PbBadge(label: l10n.historyPbBadge),
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
                  value: lungVolumeLabel(_hold.lungVolume, l10n),
                  c: c,
                ),
                if (_hold.contractionTime != null)
                  _DetailStat(
                    label: l10n.resultContraction,
                    value: fmtHoldDuration(_hold.contractionTime!),
                    c: c,
                  ),
                if (_hold.contractionTime != null &&
                    _hold.duration > _hold.contractionTime!)
                  _DetailStat(
                    label: l10n.resultStruggle,
                    value: fmtHoldDuration(
                      _hold.duration - _hold.contractionTime!,
                    ),
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
                            style: BreathLabTypography.label,
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
                label: Text(lungVolumeLabel(volume, l10n)),
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

class _ImstDetailSheet extends StatelessWidget {
  const _ImstDetailSheet({required this.session});

  final ImstSession session;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.imstLogTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              DateFormat('d MMM yyyy, HH:mm').format(session.createdAt),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: c.textTertiary),
            ),
            const SizedBox(height: Spacing.lg),
            Wrap(
              spacing: Spacing.xl,
              runSpacing: Spacing.sm,
              children: [
                _DetailStat(
                  label: l10n.imstLogBreathsLabel,
                  value: '${session.breaths}',
                  c: c,
                ),
                if (session.deviceLevel != null)
                  _DetailStat(
                    label: l10n.imstLogLevelLabel,
                    value: '${session.deviceLevel}',
                    c: c,
                  ),
                if (session.deviceName != null &&
                    session.deviceName!.isNotEmpty)
                  _DetailStat(
                    label: l10n.settingsImstDeviceNameLabel,
                    value: session.deviceName!,
                    c: c,
                  ),
                if (session.pimaxCmH2O != null)
                  _DetailStat(
                    label: l10n.settingsImstPimaxLabel,
                    value: '${session.pimaxCmH2O}',
                    c: c,
                  ),
              ],
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
