import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart' hide Durations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/models/hold.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import 'lung_volume_filter_chip.dart';
import 'providers.dart';
import 'time_range_selector.dart';

const _bottomLabelCount = 5;

String _fmtSeconds(double seconds) {
  final d = Duration(seconds: seconds.round());
  final m = d.inMinutes.toString().padLeft(2, '0');
  final s = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

Color _volumeColor(BreathLabColorScheme c, LungVolume volume) =>
    switch (volume) {
      LungVolume.full => c.primary,
      LungVolume.frc => c.info,
      LungVolume.empty => c.warning,
    };

/// Line chart of max-hold trend. Per Design §"Progress Chart": daily best
/// (solid, PB dots in record color) and daily average (dashed tertiary,
/// single-volume view only). 30 days, filtered by [LungVolumeFilterChip]
/// (Full by default; "All" overlays one best-only line per volume).
class ProgressChart extends ConsumerWidget {
  const ProgressChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final series = ref.watch(chartSeriesProvider);
    final days = ref.watch(chartWindowDaysProvider);
    final hasData = series.any((s) => s.stats.isNotEmpty);
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: LungVolumeFilterChip(),
        ),
        const SizedBox(height: Spacing.sm),
        Container(
          width: double.infinity,
          height: isDesktop ? 260 : 200,
          padding: const EdgeInsets.all(Spacing.lg),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(Radius.md),
          ),
          child: !hasData
              ? Center(
                  child: Text(
                    l10n.progressChartEmpty,
                    style: BreathLabTypography.bodySm.copyWith(
                      color: c.textTertiary,
                    ),
                  ),
                )
              : LineChart(_buildChartData(context, series, days)),
        ),
        const SizedBox(height: Spacing.md),
        const TimeRangeSelector(),
      ],
    );
  }

  LineChartData _buildChartData(
    BuildContext context,
    List<ChartSeries> series,
    int days,
  ) {
    final c = context.appColors;
    final today = DateTime.now();
    final windowStart = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(Duration(days: days - 1));
    final labelInterval = (days / _bottomLabelCount).ceil();
    final showAverage = series.length == 1;

    return LineChartData(
      minX: 0,
      maxX: (days - 1).toDouble(),
      minY: 0,
      lineTouchData: const LineTouchData(enabled: false),
      gridData: FlGridData(
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) =>
            FlLine(color: c.border.withValues(alpha: 0.2), strokeWidth: 0.5),
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(),
        rightTitles: const AxisTitles(),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) => Text(
              _fmtSeconds(value),
              style: BreathLabTypography.caption.copyWith(
                color: c.textTertiary,
              ),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: labelInterval.toDouble(),
            getTitlesWidget: (value, meta) {
              final date = windowStart.add(Duration(days: value.round()));
              return Padding(
                padding: const EdgeInsets.only(top: Spacing.xs),
                child: Text(
                  DateFormat('d MMM').format(date),
                  style: BreathLabTypography.caption.copyWith(
                    color: c.textTertiary,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      lineBarsData: [
        if (showAverage)
          LineChartBarData(
            spots: [
              for (final stat in series.single.stats)
                FlSpot(
                  stat.dayIndex.toDouble(),
                  stat.average.inSeconds.toDouble(),
                ),
            ],
            isCurved: false,
            color: c.textTertiary,
            barWidth: 1,
            dashArray: const [4, 4],
            dotData: const FlDotData(show: false),
          ),
        for (final s in series)
          LineChartBarData(
            spots: [
              for (final stat in s.stats)
                FlSpot(
                  stat.dayIndex.toDouble(),
                  stat.best.inSeconds.toDouble(),
                ),
            ],
            isCurved: false,
            color: _volumeColor(c, s.lungVolume),
            barWidth: 2,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) {
                final hasPb = s.stats[index].hasPb;
                return FlDotCirclePainter(
                  radius: hasPb ? 6 : 4,
                  color: hasPb ? c.recordText : _volumeColor(c, s.lungVolume),
                  strokeWidth: 0,
                );
              },
            ),
          ),
      ],
    );
  }
}
