import 'package:flutter/material.dart' hide Durations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/repositories/holds_repository.dart';
import '../../data/repositories/table_sessions_repository.dart';
import '../../domain/models/hold.dart';
import '../../domain/models/table_session.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import '../history/history_screen.dart';

String _fmt(Duration d) {
  final m = d.inMinutes.toString().padLeft(2, '0');
  final s = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

void showHeatmapDaySheet(BuildContext context, DateTime date) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => HeatmapDaySheet(date: date),
  );
}

/// Bottom sheet listing a day's holds and table sessions, opened by
/// tapping a filled cell on [CalendarHeatmap]. Tapping a hold opens its
/// detail sheet; table session rows are display-only, matching the
/// history list's current behavior.
class HeatmapDaySheet extends ConsumerWidget {
  const HeatmapDaySheet({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final holds = (ref.watch(allHoldsProvider).valueOrNull ?? const [])
        .where(
          (h) =>
              _isSameDay(h.createdAt, date) &&
              h.type != HoldType.co2 &&
              h.type != HoldType.o2,
        )
        .toList();
    final tables = (ref.watch(allTableSessionsProvider).valueOrNull ?? const [])
        .where((t) => _isSameDay(t.createdAt, date))
        .toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('d MMM yyyy').format(date),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: Spacing.md),
            for (final hold in holds)
              _DayEntryTile(
                time: DateFormat('HH:mm').format(hold.createdAt),
                label: _fmt(hold.duration),
                isPb: hold.isPb,
                onTap: () {
                  Navigator.of(context).pop();
                  showHoldDetail(context, hold);
                },
              ),
            for (final session in tables)
              _DayEntryTile(
                time: DateFormat('HH:mm').format(session.createdAt),
                label: switch (session.type) {
                  TableType.co2 => l10n.tablesCo2Toggle,
                  TableType.o2 => l10n.tablesO2Toggle,
                },
                isPb: false,
                onTap: null,
              ),
            const SizedBox(height: Spacing.lg),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.historyDetailClose),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayEntryTile extends StatelessWidget {
  const _DayEntryTile({
    required this.time,
    required this.label,
    required this.isPb,
    required this.onTap,
  });

  final String time;
  final String label;
  final bool isPb;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      title: Row(
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          if (isPb) ...[
            const SizedBox(width: Spacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: c.primarySurface,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                AppLocalizations.of(context)!.historyPbBadge,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: c.primaryText,
                ),
              ),
            ),
          ],
        ],
      ),
      trailing: Text(
        time,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: c.textTertiary),
      ),
    );
  }
}
