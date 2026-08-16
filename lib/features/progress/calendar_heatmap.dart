import 'package:flutter/material.dart' hide Durations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import 'heatmap_day_sheet.dart';
import 'providers.dart';

const _weeksShown = 12;
const _daysPerWeek = 7;
const _cellGap = 3.0;
const _legendSteps = [0, 1, 2, 4];
const _dayLabelWidth = 20.0;

/// Weekday rows that get a label to the left of the grid — every row would
/// be too dense at this cell size, so only Mon/Wed/Fri, matching the
/// convention GitHub's own contribution graph uses.
const _labeledWeekdayRows = {0, 2, 4};

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

    final today = _dateOnly(DateTime.now());
    final currentWeekStart = today.subtract(Duration(days: today.weekday - 1));
    final firstWeekStart = currentWeekStart.subtract(
      const Duration(days: 7 * (_weeksShown - 1)),
    );
    final gridDates = List.generate(
      _weeksShown * _daysPerWeek,
      (i) => firstWeekStart.add(Duration(days: i)),
    );
    final weekStarts = [
      for (var w = 0; w < _weeksShown; w++)
        firstWeekStart.add(Duration(days: 7 * w)),
    ];

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
          LayoutBuilder(
            builder: (context, constraints) {
              final gridWidth =
                  constraints.maxWidth - _dayLabelWidth - Spacing.xs;
              final cellSize =
                  ((gridWidth - (_weeksShown - 1) * _cellGap) / _weeksShown)
                      .clamp(10.0, 22.0);
              final colStep = cellSize + _cellGap;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: _dayLabelWidth + Spacing.xs,
                    ),
                    child: SizedBox(
                      height: 14,
                      child: Stack(
                        children: [
                          for (var w = 0; w < _weeksShown; w++)
                            if (w == 0 ||
                                weekStarts[w].month != weekStarts[w - 1].month)
                              Positioned(
                                left: w * colStep,
                                child: Text(
                                  DateFormat('MMM').format(weekStarts[w]),
                                  style: BreathLabTypography.caption.copyWith(
                                    color: c.textTertiary,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: Spacing.xxs),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: _dayLabelWidth,
                        child: Column(
                          children: [
                            for (var d = 0; d < _daysPerWeek; d++)
                              Padding(
                                padding: EdgeInsets.only(
                                  bottom: d == _daysPerWeek - 1 ? 0 : _cellGap,
                                ),
                                child: SizedBox(
                                  height: cellSize,
                                  child: !_labeledWeekdayRows.contains(d)
                                      ? null
                                      : Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            DateFormat('EEE').format(
                                              firstWeekStart.add(
                                                Duration(days: d),
                                              ),
                                            ),
                                            style: BreathLabTypography.caption
                                                .copyWith(
                                                  color: c.textTertiary,
                                                  fontSize: 10,
                                                ),
                                          ),
                                        ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: Spacing.xs),
                      Expanded(
                        child: Row(
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
                                          bottom: d == _daysPerWeek - 1
                                              ? 0
                                              : _cellGap,
                                        ),
                                        child: _HeatmapCell(
                                          date: gridDates[w * _daysPerWeek + d],
                                          count:
                                              data.countsByDate[gridDates[w *
                                                      _daysPerWeek +
                                                  d]] ??
                                              0,
                                          isToday:
                                              gridDates[w * _daysPerWeek + d] ==
                                              today,
                                          size: cellSize,
                                          onTap: showHeatmapDaySheet,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
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
                      // The zero-count swatch is otherwise nearly invisible
                      // against the card background.
                      border: Border.all(color: c.border, width: 0.5),
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
    required this.onTap,
  });

  final DateTime date;
  final int count;
  final bool isToday;
  final double size;

  /// Called with [date] when a cell with sessions is tapped. Cells with no
  /// sessions are a no-op, per Design Additions §1.
  final void Function(BuildContext, DateTime) onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final baseColor = _cellColor(context, count);
    // An outline with no fill at all reads as a broken/empty state rather
    // than "today" — give it a faint tint even before any sessions land.
    final fillColor = isToday && count == 0
        ? Color.lerp(baseColor, c.primary, 0.25)!
        : baseColor;
    return GestureDetector(
      onTap: count > 0 ? () => onTap(context, date) : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(Radius.xs),
          border: isToday ? Border.all(color: c.primary, width: 1) : null,
        ),
      ),
    );
  }
}
