import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

// TODO(phase-1e): add safety re-acknowledgement option here
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(appBar: AppBar(title: Text(l10n.navSettings)));
  }
}
