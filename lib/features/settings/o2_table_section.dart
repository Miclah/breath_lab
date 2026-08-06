import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/settings_repository.dart';
import '../../domain/services/o2_table_calculator.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/tokens.dart';
import 'section_header.dart';
import 'settings_slider.dart';
import 'settings_stepper.dart';
import 'table_preview.dart';

/// Settings → O₂ table section: rounds, max hold %, fixed rest, and a live
/// preview of the resulting table.
class O2TableSection extends ConsumerWidget {
  const O2TableSection({super.key});

  static const _minRounds = 4;
  static const _maxRounds = 12;
  static const _minMaxHoldPercent = 50;
  static const _maxMaxHoldPercent = 95;
  static const _minRestS = 30;
  static const _maxRestS = 180;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final (rounds, maxHoldPercent, restS) =
        ref.watch(o2TableConfigProvider).valueOrNull ?? (8, 80, 120);
    final maxMs = ref.watch(currentMaxMsProvider).valueOrNull;

    final preview = maxMs == null
        ? null
        : O2TableCalculator.compute(
            maxMs: maxMs,
            rounds: rounds,
            maxHoldPercent: maxHoldPercent / 100,
            restS: restS,
          );

    final config = ref.read(o2TableConfigProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: l10n.settingsO2Section),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.lg,
            vertical: Spacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.settingsRoundsLabel,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: Spacing.sm),
              SettingsStepper(
                value: rounds,
                min: _minRounds,
                max: _maxRounds,
                step: 1,
                format: (v) => '$v',
                onChanged: config.setRounds,
              ),
              const SizedBox(height: Spacing.xl),
              Text(
                l10n.settingsO2MaxHoldPercentLabel,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              SettingsSlider(
                value: maxHoldPercent,
                min: _minMaxHoldPercent,
                max: _maxMaxHoldPercent,
                divisions: (_maxMaxHoldPercent - _minMaxHoldPercent) ~/ 5,
                labelBuilder: (v) => '$v%',
                onCommit: config.setMaxHoldPercent,
              ),
              const SizedBox(height: Spacing.md),
              Text(
                l10n.settingsO2FixedRestLabel,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: Spacing.sm),
              SettingsStepper(
                value: restS,
                min: _minRestS,
                max: _maxRestS,
                step: 15,
                format: (v) => '${v}s',
                onChanged: config.setRestSeconds,
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
