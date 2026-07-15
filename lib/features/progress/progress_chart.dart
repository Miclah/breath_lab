import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart' hide Durations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import 'providers.dart';

const _defaultDays = 30;
const _bottomLabelCount = 5;

String _fmtSeconds(double seconds) {
  final d = Duration(seconds: seconds.round());
  final m = d.inMinutes.toString().padLeft(2, '0');
  final s = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

/// Line chart of max-hold trend. Per Design §"Progress Chart": daily best
/// (solid primary, PB dots in danger color) and daily average (dashed
/// tertiary). 30 days, Full lung volume by default.
class ProgressChart extends ConsumerWidget {
  const ProgressChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final stats = ref.watch(dailyHoldStatsProvider);
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    return Container(
      width: double.infinity,
      height: isDesktop ? 260 : 200,
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(Radius.md),
      ),
      child: stats.isEmpty
          ? Center(
              child: Text(
                l10n.progressChartEmpty,
                style: BreathLabTypography.bodySm.copyWith(
                  color: c.textTertiary,
                ),
              ),
            )
          : LineChart(_buildChartData(context, stats)),
    );
  }

  LineChartData _buildChartData(
    BuildContext context,
    List<DailyHoldStat> stats,
  ) {
    final c = context.appColors;
    final today = DateTime.now();
    final windowStart = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(const Duration(days: _defaultDays - 1));
    final labelInterval = (_defaultDays / _bottomLabelCount).ceil();

    return LineChartData(
      minX: 0,
      maxX: (_defaultDays - 1).toDouble(),
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
        LineChartBarData(
          spots: [
            for (final s in stats)
              FlSpot(s.dayIndex.toDouble(), s.average.inSeconds.toDouble()),
          ],
          isCurved: false,
          color: c.textTertiary,
          barWidth: 1,
          dashArray: const [4, 4],
          dotData: const FlDotData(show: false),
        ),
        LineChartBarData(
          spots: [
            for (final s in stats)
              FlSpot(s.dayIndex.toDouble(), s.best.inSeconds.toDouble()),
          ],
          isCurved: false,
          color: c.primary,
          barWidth: 2,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, bar, index) {
              final hasPb = stats[index].hasPb;
              return FlDotCirclePainter(
                radius: hasPb ? 6 : 4,
                color: hasPb ? c.danger : c.primary,
                strokeWidth: 0,
              );
            },
          ),
        ),
      ],
    );
  }
}
