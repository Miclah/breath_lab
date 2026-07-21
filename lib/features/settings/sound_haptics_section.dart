import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/settings_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/tokens.dart';
import '../tables/providers.dart'
    show audioServiceProvider, hapticsServiceProvider;
import 'section_header.dart';

/// Settings → Sound & haptics section: sound toggle, volume slider, haptic
/// intensity selector, and test buttons that preview each.
class SoundHapticsSection extends ConsumerWidget {
  const SoundHapticsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final soundEnabled = ref.watch(soundEnabledProvider).valueOrNull ?? true;
    final volume = ref.watch(soundVolumeProvider).valueOrNull ?? 100;
    final intensity =
        ref.watch(hapticIntensityProvider).valueOrNull ??
        HapticIntensity.medium;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: l10n.settingsSoundHapticsSection),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.lg,
            vertical: Spacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.settingsSoundEnabledLabel,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  Switch(
                    value: soundEnabled,
                    onChanged: (v) async {
                      await ref
                          .read(settingsRepositoryProvider)
                          .setSoundEnabled(v);
                      ref.invalidate(soundEnabledProvider);
                    },
                  ),
                ],
              ),
              const SizedBox(height: Spacing.sm),
              Text(
                l10n.settingsSoundVolumeLabel,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Slider(
                value: volume.toDouble(),
                min: 0,
                max: 100,
                divisions: 20,
                label: '$volume%',
                onChanged: !soundEnabled
                    ? null
                    : (v) async {
                        await ref
                            .read(settingsRepositoryProvider)
                            .setSoundVolume(v.round());
                        ref.invalidate(soundVolumeProvider);
                      },
              ),
              OutlinedButton(
                onPressed: !soundEnabled
                    ? null
                    : () => ref.read(audioServiceProvider).playHoldStart(),
                child: Text(l10n.settingsTestSoundButton),
              ),
              const SizedBox(height: Spacing.xl),
              Text(
                l10n.settingsHapticIntensityLabel,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: Spacing.sm),
              SegmentedButton<HapticIntensity>(
                segments: [
                  ButtonSegment(
                    value: HapticIntensity.off,
                    label: Text(l10n.settingsHapticOff),
                  ),
                  ButtonSegment(
                    value: HapticIntensity.light,
                    label: Text(l10n.settingsHapticLight),
                  ),
                  ButtonSegment(
                    value: HapticIntensity.medium,
                    label: Text(l10n.settingsHapticMedium),
                  ),
                  ButtonSegment(
                    value: HapticIntensity.strong,
                    label: Text(l10n.settingsHapticStrong),
                  ),
                ],
                selected: {intensity},
                onSelectionChanged: (value) async {
                  await ref
                      .read(settingsRepositoryProvider)
                      .setHapticIntensity(value.first);
                  ref.invalidate(hapticIntensityProvider);
                },
              ),
              const SizedBox(height: Spacing.sm),
              OutlinedButton(
                onPressed: intensity == HapticIntensity.off
                    ? null
                    : () => ref.read(hapticsServiceProvider).contraction(),
                child: Text(l10n.settingsTestHapticButton),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
