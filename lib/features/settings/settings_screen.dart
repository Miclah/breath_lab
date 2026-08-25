import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/widgets/adaptive_page.dart';
import '../../theme/tokens.dart';
import 'about_section.dart';
import 'ambient_section.dart';
import 'appearance_section.dart';
import 'co2_table_section.dart';
import 'data_section.dart';
import 'o2_table_section.dart';
import 'section_header.dart';
import 'sound_haptics_section.dart';
import 'timer_section.dart';
import 'training_section.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSettings)),
      // The section rows pad themselves, so the page adds none of its own
      // — the two would stack.
      body: AdaptivePage(
        maxWidth: ContentWidth.reading,
        padding: EdgeInsets.zero,
        child: ListView(
          children: [
            SectionHeader(title: l10n.settingsTrainingSection),
            const TrainingSection(),
            const TimerSection(),
            const Co2TableSection(),
            const O2TableSection(),
            const AmbientSection(),
            const SoundHapticsSection(),
            SectionHeader(title: l10n.settingsAppearanceSection),
            const AppearanceSection(),
            SectionHeader(title: l10n.settingsAboutSection),
            const AboutSection(),
            SectionHeader(title: l10n.settingsDataSection),
            const DataSection(),
          ],
        ),
      ),
    );
  }
}
