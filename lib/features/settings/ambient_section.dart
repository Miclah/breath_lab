import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/settings_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/segment_label.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import '../tables/providers.dart' show ttsServiceProvider;
import 'section_header.dart';

/// Settings → Ambient mode section. Spoken callouts, TTS voice language,
/// persistent notification, PiP, OLED hold screen, and focus mode toggles.
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
    final persistentNotifEnabled =
        ref.watch(ambientPersistentNotifEnabledProvider).valueOrNull ?? true;
    final pipEnabled = ref.watch(ambientPipEnabledProvider).valueOrNull ?? true;
    final oledHoldEnabled =
        ref.watch(ambientOledHoldEnabledProvider).valueOrNull ?? false;
    final brightnessOverride =
        ref.watch(ambientBrightnessOverrideProvider).valueOrNull ??
        BrightnessOverride.current;
    final focusModeEnabled =
        ref.watch(focusModeEnabledProvider).valueOrNull ?? true;

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
                    label: SegmentLabel(l10n.settingsCalloutsOff),
                  ),
                  ButtonSegment(
                    value: SpokenCalloutsMode.milestones,
                    label: SegmentLabel(l10n.settingsCalloutsMilestones),
                  ),
                  ButtonSegment(
                    value: SpokenCalloutsMode.every30s,
                    label: SegmentLabel(l10n.settingsCallouts30s),
                  ),
                  ButtonSegment(
                    value: SpokenCalloutsMode.every15s,
                    label: SegmentLabel(l10n.settingsCallouts15s),
                  ),
                  ButtonSegment(
                    value: SpokenCalloutsMode.dense,
                    label: SegmentLabel(l10n.settingsCalloutsDense),
                  ),
                ],
                selected: {calloutsMode},
                showSelectedIcon: false,
                onSelectionChanged: (value) => ref
                    .read(spokenCalloutsModeProvider.notifier)
                    .set(value.first),
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
                    label: SegmentLabel(l10n.settingsLanguageSlovak),
                  ),
                  ButtonSegment(
                    value: 'en',
                    label: SegmentLabel(l10n.settingsLanguageEnglish),
                  ),
                  ButtonSegment(
                    value: null,
                    label: SegmentLabel(l10n.settingsTtsLanguageFollowApp),
                  ),
                ],
                selected: {ttsLanguage},
                showSelectedIcon: false,
                onSelectionChanged: (value) async {
                  await ref.read(ttsLanguageProvider.notifier).set(value.first);
                  if (value.first == 'sk' &&
                      !await ref
                          .read(ttsServiceProvider)
                          .isLanguageAvailable('sk-SK')) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.settingsTtsVoiceMissing)),
                    );
                  }
                },
              ),
              const SizedBox(height: Spacing.md),
            ],
          ),
        ),
        _AmbientToggleRow(
          icon: Icons.notifications_active_outlined,
          label: l10n.settingsAmbientPersistentNotifLabel,
          subtitle: l10n.settingsAmbientPersistentNotifSubtitle,
          value: persistentNotifEnabled,
          onChanged: ref
              .read(ambientPersistentNotifEnabledProvider.notifier)
              .set,
        ),
        _AmbientToggleRow(
          icon: Icons.picture_in_picture_alt_outlined,
          label: l10n.settingsAmbientPipLabel,
          subtitle: l10n.settingsAmbientPipSubtitle,
          value: pipEnabled,
          onChanged: ref.read(ambientPipEnabledProvider.notifier).set,
        ),
        _AmbientToggleRow(
          icon: Icons.brightness_1_outlined,
          label: l10n.settingsAmbientOledHoldLabel,
          subtitle: l10n.settingsAmbientOledHoldSubtitle,
          value: oledHoldEnabled,
          onChanged: ref.read(ambientOledHoldEnabledProvider.notifier).set,
        ),
        if (oledHoldEnabled)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.lg,
              Spacing.md,
              Spacing.lg,
              Spacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.settingsBrightnessOverrideLabel,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: Spacing.sm),
                SegmentedButton<BrightnessOverride>(
                  segments: [
                    ButtonSegment(
                      value: BrightnessOverride.low,
                      label: SegmentLabel(l10n.settingsBrightnessOverrideLow),
                    ),
                    ButtonSegment(
                      value: BrightnessOverride.current,
                      label: SegmentLabel(
                        l10n.settingsBrightnessOverrideCurrent,
                      ),
                    ),
                    ButtonSegment(
                      value: BrightnessOverride.off,
                      label: SegmentLabel(l10n.settingsBrightnessOverrideOff),
                    ),
                  ],
                  selected: {brightnessOverride},
                  showSelectedIcon: false,
                  onSelectionChanged: (value) => ref
                      .read(ambientBrightnessOverrideProvider.notifier)
                      .set(value.first),
                ),
              ],
            ),
          ),
        _AmbientToggleRow(
          icon: Icons.notifications_off_outlined,
          label: l10n.settingsFocusModeLabel,
          subtitle: '',
          value: focusModeEnabled,
          onChanged: ref.read(focusModeEnabledProvider.notifier).set,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.lg,
            Spacing.sm,
            Spacing.lg,
            Spacing.md,
          ),
          child: Text(
            l10n.settingsFocusModeExplanation,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: c.textTertiary),
          ),
        ),
      ],
    );
  }
}

/// Single ambient-mode toggle row: icon, label + subtitle, switch. Per
/// Design Additions §7 toggle group visual.
class _AmbientToggleRow extends StatelessWidget {
  const _AmbientToggleRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: c.border, width: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: c.textSecondary),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.bodyMedium),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: c.textSecondary),
                  ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
