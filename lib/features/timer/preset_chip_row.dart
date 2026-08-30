import 'package:flutter/material.dart' hide Durations;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/settings_repository.dart';
import '../../domain/models/hold.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import 'providers.dart';

class PresetChipRow extends ConsumerWidget {
  const PresetChipRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final explicitChoice = ref.watch(selectedPresetProvider);
    final defaultMode =
        ref.watch(defaultPrepModeProvider).valueOrNull ?? PrepMode.threeSeconds;
    final selected = explicitChoice ?? defaultMode;

    final chips = [
      (PrepMode.none, l10n.presetQuickMax, l10n.presetQuickMaxTooltip),
      (PrepMode.threeSeconds, l10n.presetStandard, l10n.presetStandardTooltip),
      (PrepMode.full, l10n.presetFullSession, l10n.presetFullSessionTooltip),
    ];

    Widget buildChip(PrepMode mode, String label, String tooltip) {
      return _PresetChip(
        label: label,
        tooltip: tooltip,
        isSelected: selected == mode,
        onTap: () => ref.read(selectedPresetProvider.notifier).state = mode,
      );
    }

    // Equal thirds at every width. The desktop branch used to size the chips
    // to their labels, which overflows the row as soon as the content column
    // is narrower than the three natural widths plus their gaps — and the
    // column is narrower than the window by the navigation rail, so a window
    // comfortably past the desktop breakpoint could still be too narrow.
    return Row(
      children: [
        for (final (i, entry) in chips.indexed) ...[
          if (i > 0) const SizedBox(width: Spacing.md),
          Expanded(child: buildChip(entry.$1, entry.$2, entry.$3)),
        ],
      ],
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.label,
    required this.tooltip,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String tooltip;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;

    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: Durations.fast,
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
          decoration: BoxDecoration(
            // Matches the selected/unselected pattern _TagChip already
            // uses — surfaceElevated read as more prominent than the
            // primary-tinted fill, so the selected chip looked weaker
            // than the other two instead of standing out.
            color: isSelected ? c.primarySurface : Colors.transparent,
            borderRadius: BorderRadius.circular(Radius.lg),
            border: Border.all(
              color: isSelected ? c.primary : c.border,
              width: 0.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: isSelected ? c.primaryText : c.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
