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
import 'section_index.dart';
import 'sound_haptics_section.dart';
import 'timer_section.dart';
import 'training_section.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  /// One key per section, created once and kept. Rebuilding them each frame
  /// would hand the index a set of anchors that no longer point at anything.
  final _anchors = List.generate(4, (_) => GlobalKey());

  List<SettingsSection> _sections(AppLocalizations l10n) => [
    SettingsSection(
      anchor: _anchors[0],
      title: l10n.settingsTrainingSection,
      body: const Column(
        children: [
          TrainingSection(),
          TimerSection(),
          Co2TableSection(),
          O2TableSection(),
          AmbientSection(),
          SoundHapticsSection(),
        ],
      ),
    ),
    SettingsSection(
      anchor: _anchors[1],
      title: l10n.settingsAppearanceSection,
      body: const AppearanceSection(),
    ),
    SettingsSection(
      anchor: _anchors[2],
      title: l10n.settingsAboutSection,
      body: const AboutSection(),
    ),
    SettingsSection(
      anchor: _anchors[3],
      title: l10n.settingsDataSection,
      body: const DataSection(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sections = _sections(l10n);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSettings)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final split = AdaptivePage.showsSide(
            constraints.maxWidth,
            maxWidth: ContentWidth.form,
          );

          // Design §Layout puts Settings at 520, not the 600 default: it is
          // a list of rows to tap through, and rows get harder to associate
          // with their controls the wider they run.
          //
          // The page keeps the edge margin. The `Spacing.lg` the section
          // rows carry is row inset — the gap between a row's border and its
          // label — not page padding, so the two are meant to add up.
          return AdaptivePage(
            maxWidth: ContentWidth.form,
            side: !split ? null : SectionIndex(sections: sections),
            // A Column in a scroll view rather than a ListView: the index
            // scrolls to a section by its key, and a lazy list has no
            // element — and so no context — for a section that has never
            // been on screen. The form is a fixed handful of sections, so
            // building all of it costs nothing worth the indirection.
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final section in sections) ...[
                    SectionHeader(key: section.anchor, title: section.title),
                    section.body,
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
