import 'package:flutter/material.dart' hide Durations;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/settings_repository.dart';
import '../../domain/models/table_session.dart';
import '../../domain/services/co2_table_calculator.dart';
import '../../domain/services/o2_table_calculator.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import 'providers.dart';
import 'round_list_item.dart';

// Default table config per PRD §1 — configurable in Settings in a later phase.
const _co2Rounds = 7;
const _co2HoldPercent = 0.5;
const _co2RestDecrementS = 15;
const _o2Rounds = 8;
const _o2MaxHoldPercent = 0.8;
const _o2RestS = 120;

List<TableRoundPlan> _computeRounds(TableType type, int maxMs) {
  return switch (type) {
    TableType.co2 => CO2TableCalculator.compute(
      maxMs: maxMs,
      rounds: _co2Rounds,
      holdPercent: _co2HoldPercent,
      restDecrementS: _co2RestDecrementS,
    ),
    TableType.o2 => O2TableCalculator.compute(
      maxMs: maxMs,
      rounds: _o2Rounds,
      maxHoldPercent: _o2MaxHoldPercent,
      restS: _o2RestS,
    ),
  };
}

class TablesScreen extends ConsumerWidget {
  const TablesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selectedType = ref.watch(selectedTableTypeProvider);
    final maxMsAsync = ref.watch(currentMaxMsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navTables)),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(Spacing.lg),
            child: _TablePillToggle(),
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
                final rounds = _computeRounds(selectedType, maxMs);
                return Column(
                  children: [
                    _InfoCard(maxMs: maxMs, l10n: l10n),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.lg,
                        ),
                        itemCount: rounds.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: Spacing.sm),
                        itemBuilder: (context, i) => RoundListItem(
                          number: i + 1,
                          round: rounds[i],
                          state: RoundItemState.upcoming,
                        ),
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
    );
  }
}

class _TablePillToggle extends ConsumerWidget {
  const _TablePillToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final selected = ref.watch(selectedTableTypeProvider);

    return Container(
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
            onTap: () => ref.read(selectedTableTypeProvider.notifier).state =
                TableType.co2,
          ),
          _PillSegment(
            label: l10n.tablesO2Toggle,
            selected: selected == TableType.o2,
            onTap: () => ref.read(selectedTableTypeProvider.notifier).state =
                TableType.o2,
          ),
        ],
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
  final VoidCallback onTap;

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
