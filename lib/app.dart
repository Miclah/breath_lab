import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/repositories/settings_repository.dart';
import 'features/safety/safety_provider.dart';
import 'features/safety/safety_screen.dart';
import 'features/settings/theme_mode_provider.dart';
import 'features/shell/app_shell.dart';
import 'l10n/app_localizations.dart';
import 'theme/theme_data.dart';

class BreathLabApp extends ConsumerWidget {
  const BreathLabApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safetyAsync = ref.watch(safetyAcknowledgedProvider);
    final themeMode =
        ref.watch(themeModeProvider).valueOrNull ?? ThemeMode.system;
    final appLanguage = ref.watch(appLanguageProvider).valueOrNull;

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: appLanguage == null ? null : Locale(appLanguage),
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: themeMode,
      home: safetyAsync.when(
        data: (acknowledged) =>
            acknowledged ? const AppShell() : const SafetyScreen(),
        loading: () => const Scaffold(body: SizedBox.shrink()),
        error: (err, st) => const AppShell(),
      ),
    );
  }
}
