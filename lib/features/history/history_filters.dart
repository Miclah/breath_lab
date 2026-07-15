import 'package:flutter/material.dart' hide Durations;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/tags_repository.dart';
import '../../domain/models/hold.dart';
import '../../domain/models/table_session.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import 'history_screen.dart' show tagLabel;

/// Type filter for the History screen. Standalone max holds vs. the two
/// table session types.
enum HistoryTypeFilter { max, co2, o2 }

/// Selected type filters. Empty means no restriction (show every type) --
/// each chip narrows the list further once selected.
final historyTypeFilterProvider = StateProvider<Set<HistoryTypeFilter>>(
  (ref) => {},
);

/// Selected lung volume filters. Empty means no restriction.
final historyLungVolumeFilterProvider = StateProvider<Set<LungVolume>>(
  (ref) => {},
);

/// Selected tag id filters. Empty means no restriction.
final historyTagFilterProvider = StateProvider<Set<String>>((ref) => {});

/// True if [hold] passes the type/lung-volume/tag filters. Filters combine
/// with AND; an empty filter set never excludes anything.
bool holdMatchesHistoryFilters(
  Hold hold, {
  required Set<HistoryTypeFilter> types,
  required Set<LungVolume> lungVolumes,
  required Set<String> tagFilter,
  required Set<String> holdTagIds,
}) {
  if (types.isNotEmpty && !types.contains(HistoryTypeFilter.max)) {
    return false;
  }
  if (lungVolumes.isNotEmpty && !lungVolumes.contains(hold.lungVolume)) {
    return false;
  }
  if (tagFilter.isNotEmpty && !tagFilter.any(holdTagIds.contains)) {
    return false;
  }
  return true;
}

/// True if [session] passes the type filter. Table sessions have no tags
/// or lung volume, so only the type filter applies to them.
bool tableSessionMatchesHistoryFilters(
  TableSession session,
  Set<HistoryTypeFilter> types,
) {
  if (types.isEmpty) return true;
  final filterType = session.type == TableType.co2
      ? HistoryTypeFilter.co2
      : HistoryTypeFilter.o2;
  return types.contains(filterType);
}

/// Filter chip row at the top of the History screen: type, lung volume,
/// and a tag multi-select opened via bottom sheet. Combinable.
class HistoryFilterBar extends ConsumerWidget {
  const HistoryFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final types = ref.watch(historyTypeFilterProvider);
    final lungVolumes = ref.watch(historyLungVolumeFilterProvider);
    final tagFilter = ref.watch(historyTagFilterProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.xl,
        vertical: Spacing.sm,
      ),
      child: Row(
        children: [
          for (final type in HistoryTypeFilter.values) ...[
            _FilterChip(
              label: switch (type) {
                HistoryTypeFilter.max => l10n.historyFilterMax,
                HistoryTypeFilter.co2 => l10n.tablesCo2Toggle,
                HistoryTypeFilter.o2 => l10n.tablesO2Toggle,
              },
              selected: types.contains(type),
              onTap: () => _toggle(ref, historyTypeFilterProvider, type),
            ),
            const SizedBox(width: Spacing.sm),
          ],
          for (final volume in LungVolume.values) ...[
            _FilterChip(
              label: switch (volume) {
                LungVolume.full => l10n.lungVolFull,
                LungVolume.frc => l10n.lungVolFrc,
                LungVolume.empty => l10n.lungVolEmpty,
              },
              selected: lungVolumes.contains(volume),
              onTap: () =>
                  _toggle(ref, historyLungVolumeFilterProvider, volume),
            ),
            const SizedBox(width: Spacing.sm),
          ],
          _FilterChip(
            label: tagFilter.isEmpty
                ? l10n.historyFilterTags
                : '${l10n.historyFilterTags} (${tagFilter.length})',
            selected: tagFilter.isNotEmpty,
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => const _TagFilterSheet(),
            ),
          ),
        ],
      ),
    );
  }

  void _toggle<T>(WidgetRef ref, StateProvider<Set<T>> provider, T value) {
    final next = Set<T>.from(ref.read(provider));
    next.contains(value) ? next.remove(value) : next.add(value);
    ref.read(provider.notifier).state = next;
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.xs,
        ),
        decoration: BoxDecoration(
          color: selected ? c.primarySurface : Colors.transparent,
          border: Border.all(
            color: selected ? c.primary : c.border,
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(Radius.pill),
        ),
        child: Text(
          label,
          style: BreathLabTypography.badge.copyWith(
            color: selected ? c.primaryText : c.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _TagFilterSheet extends ConsumerWidget {
  const _TagFilterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final tagsAsync = ref.watch(builtInTagsProvider);
    final selected = ref.watch(historyTagFilterProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.historyFilterTagsSheetTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: Spacing.lg),
            tagsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => const SizedBox.shrink(),
              data: (tags) => Wrap(
                spacing: Spacing.sm,
                runSpacing: Spacing.sm,
                children: [
                  for (final tag in tags)
                    _FilterChip(
                      label: tagLabel(tag.labelKey, l10n),
                      selected: selected.contains(tag.id),
                      onTap: () {
                        final next = Set<String>.from(selected);
                        next.contains(tag.id)
                            ? next.remove(tag.id)
                            : next.add(tag.id);
                        ref.read(historyTagFilterProvider.notifier).state =
                            next;
                      },
                    ),
                ],
              ),
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
