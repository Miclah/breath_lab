import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/tokens.dart';
import 'co2_table_section.dart';
import 'o2_table_section.dart';
import 'section_header.dart';
import 'sound_haptics_section.dart';
import 'theme_mode_provider.dart';
import 'timer_section.dart';
import 'training_section.dart';

// TODO(phase-1e): add safety re-acknowledgement option here
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final themeMode =
        ref.watch(themeModeProvider).valueOrNull ?? ThemeMode.system;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSettings)),
      body: ListView(
        children: [
          SectionHeader(title: l10n.settingsTrainingSection),
          const TrainingSection(),
          const TimerSection(),
          const Co2TableSection(),
          const O2TableSection(),
          const SoundHapticsSection(),
          SectionHeader(title: l10n.settingsAppearanceSection),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: Spacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.settingsThemeLabel,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: Spacing.sm),
                SegmentedButton<ThemeMode>(
                  segments: [
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text(l10n.themeDark),
                      icon: const Icon(Icons.dark_mode_outlined),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text(l10n.themeLight),
                      icon: const Icon(Icons.light_mode_outlined),
                    ),
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text(l10n.themeSystem),
                      icon: const Icon(Icons.brightness_auto_outlined),
                    ),
                  ],
                  selected: {themeMode},
                  onSelectionChanged: (selected) => ref
                      .read(themeModeProvider.notifier)
                      .setMode(selected.first),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
