import 'package:flutter/material.dart' hide Durations;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/settings_repository.dart';
import '../../domain/models/table_session.dart';
import '../../domain/services/co2_table_calculator.dart';
import '../../domain/services/o2_table_calculator.dart';
import '../../domain/services/table_session_state.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/content_max_width.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import 'providers.dart';
import 'round_list_item.dart';
import 'session_summary_view.dart';
import 'table_session_notifier.dart';

List<TableRoundPlan> _computeRounds(
  TableType type,
  int maxMs, {
  required (int, int, int) co2Config,
  required (int, int, int) o2Config,
}) {
  return switch (type) {
    TableType.co2 => CO2TableCalculator.compute(
      maxMs: maxMs,
      rounds: co2Config.$1,
      holdPercent: co2Config.$2 / 100,
      restDecrementS: co2Config.$3,
    ),
    TableType.o2 => O2TableCalculator.compute(
      maxMs: maxMs,
      rounds: o2Config.$1,
      maxHoldPercent: o2Config.$2 / 100,
      restS: o2Config.$3,
    ),
  };
}

RoundItemState _stateFor(TableSessionState session, bool active, int index) {
  if (!active) return RoundItemState.upcoming;
  if (index < session.completedRounds.length) return RoundItemState.completed;
  if (index == session.currentRoundIndex && !session.isDone) {
    return RoundItemState.active;
  }
  return RoundItemState.upcoming;
}

class TablesScreen extends ConsumerWidget {
  const TablesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selectedType = ref.watch(selectedTableTypeProvider);
    final maxMsAsync = ref.watch(currentMaxMsProvider);
    final co2Config =
        ref.watch(co2TableConfigProvider).valueOrNull ?? (7, 50, 15);
    final o2Config =
        ref.watch(o2TableConfigProvider).valueOrNull ?? (8, 80, 120);
    final session = ref.watch(tableSessionProvider);
    final sessionActive = !session.isIdle;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navTables)),
      body: ContentMaxWidth(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(Spacing.lg),
              child: _TablePillToggle(enabled: !sessionActive),
            ),
            Expanded(
              child: maxMsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => const SizedBox.shrink(),
                data: (maxMs) {
                  if (maxMs == null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.xxl,
                        ),
                        child: Text(
                          l10n.tablesNoMaxYet,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    );
                  }
                  final rounds = sessionActive
                      ? session.rounds
                      : _computeRounds(
                          selectedType,
                          maxMs,
                          co2Config: co2Config,
                          o2Config: o2Config,
                        );
                  return Column(
                    children: [
                      if (session.isDone)
                        Expanded(child: SessionSummaryView(session: session))
                      else ...[
                        _InfoCard(maxMs: maxMs, l10n: l10n),
                        Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Spacing.lg,
                            ),
                            itemCount: rounds.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: Spacing.sm),
                            itemBuilder: (context, i) {
                              final itemState = _stateFor(
                                session,
                                sessionActive,
                                i,
                              );
                              final isActive =
                                  itemState == RoundItemState.active;
                              return RoundListItem(
                                number: i + 1,
                                round: rounds[i],
                                state: itemState,
                                elapsedMs: isActive
                                    ? session.elapsed.inMilliseconds
                                    : null,
                                phaseLabel: !isActive
                                    ? null
                                    : session.isHolding
                                    ? l10n.tablesPhaseLabelHold
                                    : l10n.tablesPhaseLabelRest,
                                onStopHold: isActive && session.isHolding
                                    ? () => ref
                                          .read(tableSessionProvider.notifier)
                                          .stopHoldEarly()
                                    : null,
                              );
                            },
                          ),
                        ),
                      ],
                      const SizedBox(height: Spacing.lg),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.lg,
                        ),
                        child: _SessionActionButton(
                          sessionActive: sessionActive,
                          isDone: session.isDone,
                          l10n: l10n,
                          onStart: () => ref
                              .read(tableSessionProvider.notifier)
                              .start(selectedType, rounds, maxMs),
                          onReset: () =>
                              ref.read(tableSessionProvider.notifier).reset(),
                          onStop: () => ref
                              .read(tableSessionProvider.notifier)
                              .stopSession(),
                        ),
                      ),
                      const SizedBox(height: Spacing.lg),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionActionButton extends StatelessWidget {
  const _SessionActionButton({
    required this.sessionActive,
    required this.isDone,
    required this.l10n,
    required this.onStart,
    required this.onReset,
    required this.onStop,
  });

  final bool sessionActive;
  final bool isDone;
  final AppLocalizations l10n;
  final VoidCallback onStart;
  final VoidCallback onReset;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;

    if (sessionActive && !isDone) {
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: c.danger,
            foregroundColor: c.textOnDanger,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Radius.lg),
            ),
          ),
          onPressed: onStop,
          child: Text(l10n.timerStopButton),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radius.lg),
          ),
        ),
        onPressed: isDone ? onReset : onStart,
        child: Text(l10n.timerStartButton),
      ),
    );
  }
}

class _TablePillToggle extends ConsumerWidget {
  const _TablePillToggle({required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final selected = ref.watch(selectedTableTypeProvider);

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Container(
        decoration: BoxDecoration(
          color: c.surfaceElevated,
          borderRadius: BorderRadius.circular(Radius.pill),
        ),
        padding: const EdgeInsets.all(Spacing.xxs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PillSegment(
              label: l10n.tablesCo2Toggle,
              selected: selected == TableType.co2,
              onTap: !enabled
                  ? null
                  : () => ref.read(selectedTableTypeProvider.notifier).state =
                        TableType.co2,
            ),
            _PillSegment(
              label: l10n.tablesO2Toggle,
              selected: selected == TableType.o2,
              onTap: !enabled
                  ? null
                  : () => ref.read(selectedTableTypeProvider.notifier).state =
                        TableType.o2,
            ),
          ],
        ),
      ),
    );
  }
}

class _PillSegment extends StatelessWidget {
  const _PillSegment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Radius.pill),
      child: AnimatedContainer(
        duration: Durations.normal,
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.xl,
          vertical: Spacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? c.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(Radius.pill),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: selected ? c.textOnPrimary : c.textTertiary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.maxMs, required this.l10n});

  final int maxMs;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(Spacing.lg, 0, Spacing.lg, Spacing.lg),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          color: c.surfaceElevated,
          borderRadius: BorderRadius.circular(Radius.md),
        ),
        child: Text(
          l10n.tablesBasedOnMax(formatRoundMs(maxMs)),
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: c.textSecondary),
        ),
      ),
    );
  }
}
