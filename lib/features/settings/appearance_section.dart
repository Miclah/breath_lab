import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/settings_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/tokens.dart';
import 'theme_mode_provider.dart';

/// Settings → Appearance section: theme mode and app UI language.
class AppearanceSection extends ConsumerWidget {
  const AppearanceSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final themeMode =
        ref.watch(themeModeProvider).valueOrNull ?? ThemeMode.system;
    final appLanguage = ref.watch(appLanguageProvider).valueOrNull;

    return Padding(
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
            showSelectedIcon: false,
            onSelectionChanged: (selected) =>
                ref.read(themeModeProvider.notifier).setMode(selected.first),
          ),
          const SizedBox(height: Spacing.xl),
          Text(
            l10n.settingsAppLanguageLabel,
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
              ButtonSegment(value: null, label: Text(l10n.themeSystem)),
            ],
            selected: {appLanguage},
            showSelectedIcon: false,
            onSelectionChanged: (selected) =>
                ref.read(appLanguageProvider.notifier).set(selected.first),
          ),
        ],
      ),
    );
  }
}
