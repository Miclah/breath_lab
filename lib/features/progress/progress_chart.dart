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

/// Candidate gridline intervals, in seconds — kept to round numbers so
/// adjacent Y-axis labels never round to the same mm:ss text.
const _niceIntervalsSeconds = [5, 10, 15, 30, 60, 120, 300, 600, 900, 1800];

String _fmtSeconds(double seconds) {
  final d = Duration(seconds: seconds.round());
  final m = d.inMinutes.toString().padLeft(2, '0');
  final s = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

/// Smallest candidate from [_niceIntervalsSeconds] that keeps the Y axis to
/// roughly 4 gridlines for the given max value.
double _niceInterval(double maxSeconds) {
  for (final step in _niceIntervalsSeconds) {
    if (maxSeconds / step <= 4) return step.toDouble();
  }
  return (maxSeconds / 4).ceilToDouble();
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
    final showAverage = series.length == 1;

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
          // Extra right inset beyond the rest of the card's padding — the
          // last data point and its date label otherwise land right on the
          // card's edge and get visually clipped.
          padding: const EdgeInsets.fromLTRB(
            Spacing.lg,
            Spacing.lg,
            Spacing.lg + 12,
            Spacing.lg,
          ),
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
        if (hasData && showAverage) ...[
          const SizedBox(height: Spacing.xs),
          Align(
            alignment: Alignment.centerRight,
            child: _AverageLegend(label: l10n.progressChartAverageLegend),
          ),
        ],
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

    var maxSeconds = 0.0;
    for (final s in series) {
      for (final stat in s.stats) {
        if (stat.best.inSeconds > maxSeconds) {
          maxSeconds = stat.best.inSeconds.toDouble();
        }
        if (showAverage && stat.average.inSeconds > maxSeconds) {
          maxSeconds = stat.average.inSeconds.toDouble();
        }
      }
    }
    final yInterval = _niceInterval(maxSeconds <= 0 ? 60 : maxSeconds);
    final maxY = maxSeconds <= 0
        ? yInterval
        : (maxSeconds / yInterval).ceil() * yInterval;

    return LineChartData(
      minX: 0,
      maxX: (days - 1).toDouble(),
      minY: 0,
      maxY: maxY,
      lineTouchData: const LineTouchData(enabled: false),
      gridData: FlGridData(
        drawVerticalLine: false,
        horizontalInterval: yInterval,
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
            interval: yInterval,
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

/// Dash sample + label explaining the dashed daily-average line, since a
/// gray dashed curve crossing a colored solid one otherwise has no way to
/// read as "average" rather than a rendering artifact.
class _AverageLegend extends StatelessWidget {
  const _AverageLegend({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 3; i++)
          Container(
            width: 4,
            height: 1,
            margin: EdgeInsets.only(right: i < 2 ? 2 : 0),
            color: c.textTertiary,
          ),
        const SizedBox(width: Spacing.xs),
        Text(
          label,
          style: BreathLabTypography.caption.copyWith(color: c.textTertiary),
        ),
      ],
    );
  }
}
