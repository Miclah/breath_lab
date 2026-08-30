import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart' hide Durations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/models/hold.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/surfaces.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import 'lung_volume_filter_chip.dart';
import 'providers.dart';
import 'time_range_selector.dart';
import 'start_hold_button.dart';

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
/// Below this the chart shows copy instead of a line. A line needs points.
const _minimumPointsForATrend = 4;

class ProgressChart extends ConsumerWidget {
  const ProgressChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final series = ref.watch(chartSeriesProvider);
    final days = ref.watch(chartWindowDaysProvider);
    // Design Revision §5: four points, not one. Two points is a segment and
    // three is barely a direction; drawing either invites the user to read a
    // trend out of noise, which is worse than saying there isn't one yet.
    final pointCount = series.fold<int>(0, (sum, s) => sum + s.stats.length);
    final hasData = pointCount >= _minimumPointsForATrend;
    final isDesktop = MediaQuery.of(context).size.width >= 600;
    // The dashed average and the struggle-phase line both only make sense
    // over a single volume — overlaid three-deep in "All" they are noise.
    final showExtras = series.length == 1;
    final hasStruggle =
        showExtras &&
        series.single.stats.any((s) => s.bestStruggle > Duration.zero);

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
          // The screen's one primary panel: the trend line is what a
          // Progress screen is for, and the teal top edge is what says so.
          decoration: Surfaces.primaryPanel(context),
          child: !hasData
              ? const _ChartEmptyState()
              : LineChart(_buildChartData(context, series, days, hasStruggle)),
        ),
        if (hasData && showExtras) ...[
          const SizedBox(height: Spacing.xs),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: Spacing.md,
              runSpacing: Spacing.xxs,
              children: [
                if (hasStruggle)
                  _ChartLegend(
                    color: _volumeColor(
                      context.appColors,
                      series.single.lungVolume,
                    ).withValues(alpha: 0.5),
                    label: l10n.progressChartStruggleLegend,
                  ),
                _ChartLegend(
                  color: context.appColors.textTertiary,
                  dashed: true,
                  label: l10n.progressChartAverageLegend,
                ),
              ],
            ),
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
    bool showStruggle,
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
              style: BreathLabTypography.micro.copyWith(color: c.textTertiary),
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
                  style: BreathLabTypography.micro.copyWith(
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
        if (showStruggle)
          LineChartBarData(
            spots: [
              for (final stat in series.single.stats)
                if (stat.bestStruggle > Duration.zero)
                  FlSpot(
                    stat.dayIndex.toDouble(),
                    stat.bestStruggle.inSeconds.toDouble(),
                  ),
            ],
            isCurved: false,
            color: _volumeColor(
              c,
              series.single.lungVolume,
            ).withValues(alpha: 0.5),
            barWidth: 1.5,
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

/// A swatch + label for one of the chart's secondary lines. A gray dashed
/// curve or a faint tinted one crossing the solid best line otherwise has no
/// way to read as anything but a rendering artifact.
class _ChartLegend extends StatelessWidget {
  const _ChartLegend({
    required this.color,
    required this.label,
    this.dashed = false,
  });

  final Color color;
  final String label;
  final bool dashed;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (dashed)
          for (var i = 0; i < 3; i++)
            Container(
              width: 4,
              height: 1,
              margin: EdgeInsets.only(right: i < 2 ? 2 : 0),
              color: color,
            )
        else
          Container(width: 14, height: 2, color: color),
        const SizedBox(width: Spacing.xs),
        Text(
          label,
          style: BreathLabTypography.micro.copyWith(color: c.textTertiary),
        ),
      ],
    );
  }
}

/// What the chart panel holds before there is a trend to draw.
///
/// Design Revision §5: a screen with no data shows what it is *for*, never an
/// empty rendering of what it will become. The second line is the first place
/// the research reaches the UI — `RESEARCH_ALIGNMENT.md` §2 records that
/// 59.7 % of measured novice improvement sits in the struggle phase, so a
/// beginner watching their total time is watching the wrong number.
class _ChartEmptyState extends StatelessWidget {
  const _ChartEmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.progressChartEmpty,
            textAlign: TextAlign.center,
            style: BreathLabTypography.body.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            l10n.progressChartEmptyWhy,
            textAlign: TextAlign.center,
            style: BreathLabTypography.micro.copyWith(color: c.textTertiary),
          ),
          const SizedBox(height: Spacing.lg),
          const StartHoldButton(),
        ],
      ),
    );
  }
}
