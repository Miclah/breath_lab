import 'package:flutter/material.dart' hide Durations;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import 'providers.dart';

const _weeksShown = 12;
const _daysPerWeek = 7;
const _cellGap = 3.0;
const _legendSteps = [0, 1, 2, 4];

Color _cellColor(BuildContext context, int count) {
  final c = context.appColors;
  final isDark = Theme.of(context).brightness == Brightness.dark;
  if (count <= 0) return isDark ? c.border.withValues(alpha: 0.4) : c.border;
  if (count == 1) return c.primarySurface;
  if (count <= 3) return c.primary;
  return c.primaryText;
}

DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

/// GitHub-style contribution heatmap of training days over the last 12
/// weeks. Per Design Additions §1. Tap-to-drill-down is added separately.
class CalendarHeatmap extends ConsumerWidget {
  const CalendarHeatmap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final data = ref.watch(heatmapDataProvider);
    final isDesktop = MediaQuery.of(context).size.width >= 600;
    final cellSize = isDesktop ? 18.0 : 14.0;

    final today = _dateOnly(DateTime.now());
    final currentWeekStart = today.subtract(Duration(days: today.weekday - 1));
    final firstWeekStart = currentWeekStart.subtract(
      const Duration(days: 7 * (_weeksShown - 1)),
    );
    final gridDates = List.generate(
      _weeksShown * _daysPerWeek,
      (i) => firstWeekStart.add(Duration(days: i)),
    );

    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: c.surfaceElevated,
        borderRadius: BorderRadius.circular(Radius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.progressHeatmapTitle.toUpperCase(),
            style: BreathLabTypography.caption.copyWith(
              color: c.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var w = 0; w < _weeksShown; w++)
                Padding(
                  padding: EdgeInsets.only(
                    right: w == _weeksShown - 1 ? 0 : _cellGap,
                  ),
                  child: Column(
                    children: [
                      for (var d = 0; d < _daysPerWeek; d++)
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: d == _daysPerWeek - 1 ? 0 : _cellGap,
                          ),
                          child: _HeatmapCell(
                            date: gridDates[w * _daysPerWeek + d],
                            count:
                                data.countsByDate[gridDates[w * _daysPerWeek +
                                    d]] ??
                                0,
                            isToday: gridDates[w * _daysPerWeek + d] == today,
                            size: cellSize,
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              Text(
                l10n.progressHeatmapLegendLess,
                style: BreathLabTypography.caption.copyWith(
                  color: c.textTertiary,
                ),
              ),
              const SizedBox(width: Spacing.xs),
              for (final step in _legendSteps)
                Padding(
                  padding: const EdgeInsets.only(right: _cellGap),
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _cellColor(context, step),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              Text(
                l10n.progressHeatmapLegendMore,
                style: BreathLabTypography.caption.copyWith(
                  color: c.textTertiary,
                ),
              ),
              const Spacer(),
              Text(
                l10n.progressHeatmapStat(data.totalSessions, data.bestWeekDays),
                style: BreathLabTypography.caption.copyWith(
                  color: c.textTertiary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeatmapCell extends StatelessWidget {
  const _HeatmapCell({
    required this.date,
    required this.count,
    required this.isToday,
    required this.size,
  });

  final DateTime date;
  final int count;
  final bool isToday;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _cellColor(context, count),
        borderRadius: BorderRadius.circular(Radius.xs),
        border: isToday ? Border.all(color: c.primary, width: 1) : null,
      ),
    );
  }
}
