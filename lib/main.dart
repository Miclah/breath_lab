import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'theme/theme_data.dart';

void main() {
  runApp(const BreathLabApp());
}

class BreathLabApp extends StatelessWidget {
  const BreathLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: ThemeMode.system,
      home: const Scaffold(),
    );
  }
}
