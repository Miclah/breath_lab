import 'dart:math' as math;

import 'package:flutter/material.dart' hide Durations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/surfaces.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import 'heatmap_day_sheet.dart';
import 'providers.dart';

const _weeksShown = 12;
const _daysPerWeek = 7;
const _cellGap = 3.0;
const _legendSteps = [0, 1, 2, 4];

/// Weekday rows that get a label to the left of the grid — every row would
/// be too dense at this cell size, so only Mon/Wed/Fri, matching the
/// convention GitHub's own contribution graph uses.
const _labeledWeekdayRows = {0, 2, 4};

Color _cellColor(BuildContext context, int count) {
  final c = context.appColors;
  if (count <= 0) return c.heatmapEmpty;
  if (count == 1) return c.heatmapLow;
  if (count <= 3) return c.heatmapMid;
  return c.heatmapHigh;
}

/// How much room the weekday column needs for the labels it will actually
/// draw, in this locale, at this style.
///
/// A fixed 20 px fitted "Mo" and pushed the "n" onto a second line — and
/// only in English, since Slovak's two-letter abbreviations fit, so half
/// the builds never showed the bug. Any constant here is a guess about a
/// language; measuring is not.
double _dayLabelWidth(Iterable<String> labels, TextStyle style) {
  var widest = 0.0;
  for (final label in labels) {
    final painter = TextPainter(
      text: TextSpan(text: label, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    widest = math.max(widest, painter.width);
  }
  return widest;
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
    // Eighty-four identical grey squares presented as though they were a
    // reading is what a fresh install used to show. Dimmed, with a line
    // saying what fills it, it reads as a thing waiting for data rather than
    // as a thing that is broken. Design Revision §5.
    final isEmpty = data.totalSessions == 0;

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

    final axisStyle = BreathLabTypography.micro.copyWith(color: c.textTertiary);
    final dayLabels = {
      for (final d in _labeledWeekdayRows)
        d: DateFormat('EEE').format(firstWeekStart.add(Duration(days: d))),
    };
    final dayLabelWidth = _dayLabelWidth(dayLabels.values, axisStyle);

    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      // Quiet, not filled. Twelve weeks of attendance is context for the
      // chart above it, not a second subject competing with it.
      decoration: Surfaces.quietPanel(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.progressHeatmapTitle.toUpperCase(),
            style: BreathLabTypography.section.copyWith(color: c.textTertiary),
          ),
          const SizedBox(height: Spacing.sm),
          Opacity(
            opacity: isEmpty ? 0.35 : 1,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final gridWidth =
                    constraints.maxWidth - dayLabelWidth - Spacing.xs;
                final cellSize =
                    ((gridWidth - (_weeksShown - 1) * _cellGap) / _weeksShown)
                        .clamp(10.0, 22.0);
                final colStep = cellSize + _cellGap;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: dayLabelWidth + Spacing.xs,
                      ),
                      child: SizedBox(
                        height: 14,
                        child: Stack(
                          children: [
                            for (var w = 0; w < _weeksShown; w++)
                              if (w == 0 ||
                                  weekStarts[w].month !=
                                      weekStarts[w - 1].month)
                                Positioned(
                                  left: w * colStep,
                                  child: Text(
                                    DateFormat('MMM').format(weekStarts[w]),
                                    style: axisStyle,
                                    maxLines: 1,
                                    softWrap: false,
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
                          width: dayLabelWidth,
                          child: Column(
                            children: [
                              for (var d = 0; d < _daysPerWeek; d++)
                                Padding(
                                  padding: EdgeInsets.only(
                                    bottom: d == _daysPerWeek - 1
                                        ? 0
                                        : _cellGap,
                                  ),
                                  child: SizedBox(
                                    height: cellSize,
                                    child: dayLabels[d] == null
                                        ? null
                                        : Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              dayLabels[d]!,
                                              style: axisStyle,
                                              maxLines: 1,
                                              softWrap: false,
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
                                            date:
                                                gridDates[w * _daysPerWeek + d],
                                            count:
                                                data.countsByDate[gridDates[w *
                                                        _daysPerWeek +
                                                    d]] ??
                                                0,
                                            isToday:
                                                gridDates[w * _daysPerWeek +
                                                    d] ==
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
          ),
          if (isEmpty) ...[
            const SizedBox(height: Spacing.md),
            Text(
              l10n.progressHeatmapEmpty,
              style: BreathLabTypography.micro.copyWith(color: c.textTertiary),
            ),
          ],
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              Text(
                l10n.progressHeatmapLegendLess,
                style: BreathLabTypography.micro.copyWith(
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
                style: BreathLabTypography.micro.copyWith(
                  color: c.textTertiary,
                ),
              ),
              const Spacer(),
              Text(
                l10n.progressHeatmapStat(data.totalSessions, data.bestWeekDays),
                style: BreathLabTypography.micro.copyWith(
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
    // Today is marked by the ring alone. Tinting the fill as well used to be
    // needed because the empty colour was nearly invisible; now that it is a
    // real step, tinting it would invent a fifth value between empty and one
    // session and undo the separation the ramp exists for.
    return GestureDetector(
      onTap: count > 0 ? () => onTap(context, date) : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: _cellColor(context, count),
          borderRadius: BorderRadius.circular(Radius.xs),
          border: isToday ? Border.all(color: c.primary, width: 1) : null,
        ),
      ),
    );
  }
}
