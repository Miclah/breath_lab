import 'package:flutter/material.dart' hide Durations;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/hold.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import 'providers.dart';

LungVolume? _next(LungVolume? current) => switch (current) {
  LungVolume.full => LungVolume.frc,
  LungVolume.frc => LungVolume.empty,
  LungVolume.empty => null,
  null => LungVolume.full,
};

/// Cycles the progress chart's lung volume filter: Full -> FRC -> Empty
/// -> All -> Full. Per PRD §7.3.
class LungVolumeFilterChip extends ConsumerWidget {
  const LungVolumeFilterChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final filter = ref.watch(chartLungFilterProvider);
    final label = switch (filter) {
      LungVolume.full => l10n.lungVolFull,
      LungVolume.frc => l10n.lungVolFrc,
      LungVolume.empty => l10n.lungVolEmpty,
      null => l10n.progressChartFilterAll,
    };

    return GestureDetector(
      onTap: () =>
          ref.read(chartLungFilterProvider.notifier).state = _next(filter),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.xs,
        ),
        decoration: BoxDecoration(
          color: c.surfaceElevated,
          border: Border.all(color: c.border, width: 0.5),
          borderRadius: BorderRadius.circular(Radius.pill),
        ),
        child: Text(
          label,
          style: BreathLabTypography.badge.copyWith(color: c.textSecondary),
        ),
      ),
    );
  }
}
