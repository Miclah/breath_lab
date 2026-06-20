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

    final isDesktop = MediaQuery.of(context).size.width >= 600;

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

    if (isDesktop) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (i, entry) in chips.indexed) ...[
            if (i > 0) const SizedBox(width: Spacing.md),
            buildChip(entry.$1, entry.$2, entry.$3),
          ],
        ],
      );
    }

    // Mobile: equal-width chips
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
          decoration: BoxDecoration(
            color: isSelected ? c.primarySurface : c.surfaceElevated,
            borderRadius: BorderRadius.circular(Radius.lg),
            border: Border.all(
              color: isSelected ? c.primary : Colors.transparent,
              width: 0.5,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: isSelected ? c.primaryText : c.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
