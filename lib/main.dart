import 'package:flutter/material.dart';

import 'theme/theme_data.dart';

void main() {
  runApp(const BreathLabApp());
}

class BreathLabApp extends StatelessWidget {
  const BreathLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BreathLab',
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: ThemeMode.system,
      home: const Scaffold(),
    );
  }
}
