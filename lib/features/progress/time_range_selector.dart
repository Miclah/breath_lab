import 'package:flutter/material.dart' hide Durations;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import 'providers.dart';

/// Pill toggle below the progress chart: 30d / 90d / All. Per Design
/// §"Progress Chart".
class TimeRangeSelector extends ConsumerWidget {
  const TimeRangeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selected = ref.watch(chartTimeRangeProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final range in ChartTimeRange.values) ...[
          _RangePill(
            label: switch (range) {
              ChartTimeRange.d30 => l10n.progressChartRange30d,
              ChartTimeRange.d90 => l10n.progressChartRange90d,
              ChartTimeRange.all => l10n.progressChartFilterAll,
            },
            selected: range == selected,
            onTap: () =>
                ref.read(chartTimeRangeProvider.notifier).state = range,
          ),
          if (range != ChartTimeRange.values.last)
            const SizedBox(width: Spacing.sm),
        ],
      ],
    );
  }
}

class _RangePill extends StatelessWidget {
  const _RangePill({
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
          color: selected ? c.primarySurface : c.surfaceElevated,
          borderRadius: BorderRadius.circular(Radius.pill),
        ),
        child: Text(
          label,
          style: BreathLabTypography.micro.copyWith(
            color: selected ? c.primaryText : c.textTertiary,
          ),
        ),
      ),
    );
  }
}
