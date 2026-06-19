import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/safety/safety_provider.dart';
import 'features/safety/safety_screen.dart';
import 'features/shell/app_shell.dart';
import 'l10n/app_localizations.dart';
import 'theme/theme_data.dart';

class BreathLabApp extends ConsumerWidget {
  const BreathLabApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safetyAsync = ref.watch(safetyAcknowledgedProvider);

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: ThemeMode.system,
      home: safetyAsync.when(
        data: (acknowledged) =>
            acknowledged ? const AppShell() : const SafetyScreen(),
        loading: () => const Scaffold(body: SizedBox.shrink()),
        error: (err, st) => const AppShell(),
      ),
    );
  }
}
