import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/settings_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import 'section_header.dart';

/// Settings → Ambient mode section. Starts with spoken callouts mode and
/// TTS voice language; more ambient toggles (persistent notification, PiP,
/// OLED hold, focus mode, ...) land in later commits.
class AmbientSection extends ConsumerWidget {
  const AmbientSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final calloutsMode =
        ref.watch(spokenCalloutsModeProvider).valueOrNull ??
        SpokenCalloutsMode.milestones;
    final ttsLanguage = ref.watch(ttsLanguageProvider).valueOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: l10n.settingsAmbientSection),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.lg,
            vertical: Spacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.settingsAmbientIntro,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: c.textTertiary),
              ),
              const SizedBox(height: Spacing.xl),
              Text(
                l10n.settingsSpokenCalloutsLabel,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: Spacing.sm),
              SegmentedButton<SpokenCalloutsMode>(
                segments: [
                  ButtonSegment(
                    value: SpokenCalloutsMode.off,
                    label: Text(l10n.settingsCalloutsOff),
                  ),
                  ButtonSegment(
                    value: SpokenCalloutsMode.milestones,
                    label: Text(l10n.settingsCalloutsMilestones),
                  ),
                  ButtonSegment(
                    value: SpokenCalloutsMode.every30s,
                    label: Text(l10n.settingsCallouts30s),
                  ),
                  ButtonSegment(
                    value: SpokenCalloutsMode.every15s,
                    label: Text(l10n.settingsCallouts15s),
                  ),
                  ButtonSegment(
                    value: SpokenCalloutsMode.dense,
                    label: Text(l10n.settingsCalloutsDense),
                  ),
                ],
                selected: {calloutsMode},
                showSelectedIcon: false,
                onSelectionChanged: (value) async {
                  await ref
                      .read(settingsRepositoryProvider)
                      .setSpokenCalloutsMode(value.first);
                  ref.invalidate(spokenCalloutsModeProvider);
                },
              ),
              const SizedBox(height: Spacing.xl),
              Text(
                l10n.settingsTtsLanguageLabel,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: Spacing.sm),
              SegmentedButton<String?>(
                segments: [
                  ButtonSegment(
                    value: 'sk',
                    label: Text(l10n.settingsLanguageSlovak),
                  ),
                  ButtonSegment(
                    value: 'en',
                    label: Text(l10n.settingsLanguageEnglish),
                  ),
                  ButtonSegment(
                    value: null,
                    label: Text(l10n.settingsTtsLanguageFollowApp),
                  ),
                ],
                selected: {ttsLanguage},
                onSelectionChanged: (value) async {
                  await ref
                      .read(settingsRepositoryProvider)
                      .setTtsLanguage(value.first);
                  ref.invalidate(ttsLanguageProvider);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
