import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/settings_repository.dart';
import '../../domain/services/co2_table_calculator.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/tokens.dart';
import 'section_header.dart';
import 'settings_slider.dart';
import 'settings_stepper.dart';
import 'table_preview.dart';

/// Settings → CO₂ table section: rounds, hold %, rest decrement, and a live
/// preview of the resulting table.
class Co2TableSection extends ConsumerWidget {
  const Co2TableSection({super.key});

  static const _minRounds = 3;
  static const _maxRounds = 15;
  static const _minHoldPercent = 10;
  static const _maxHoldPercent = 90;
  static const _minRestDecrementS = 5;
  static const _maxRestDecrementS = 60;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final (rounds, holdPercent, restDecrementS) =
        ref.watch(co2TableConfigProvider).valueOrNull ?? (7, 50, 15);
    final maxMs = ref.watch(currentMaxMsProvider).valueOrNull;

    final preview = maxMs == null
        ? null
        : CO2TableCalculator.compute(
            maxMs: maxMs,
            rounds: rounds,
            holdPercent: holdPercent / 100,
            restDecrementS: restDecrementS,
          );

    final config = ref.read(co2TableConfigProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: l10n.settingsCo2Section),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.lg,
            vertical: Spacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SettingsStepper(
                label: l10n.settingsRoundsLabel,
                value: rounds,
                min: _minRounds,
                max: _maxRounds,
                step: 1,
                format: (v) => '$v',
                onChanged: config.setRounds,
              ),
              const SizedBox(height: Spacing.xl),
              SettingsSlider(
                label: l10n.settingsCo2HoldPercentLabel,
                value: holdPercent,
                min: _minHoldPercent,
                max: _maxHoldPercent,
                divisions: (_maxHoldPercent - _minHoldPercent) ~/ 5,
                labelBuilder: (v) => '$v%',
                onCommit: config.setHoldPercent,
              ),
              const SizedBox(height: Spacing.md),
              SettingsStepper(
                label: l10n.settingsCo2RestDecrementLabel,
                value: restDecrementS,
                min: _minRestDecrementS,
                max: _maxRestDecrementS,
                step: 5,
                format: (v) => '${v}s',
                onChanged: config.setRestDecrementSeconds,
              ),
              const SizedBox(height: Spacing.xl),
              if (preview != null)
                TablePreview(rounds: preview)
              else
                Text(
                  l10n.tablesNoMaxYet,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
