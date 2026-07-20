import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../progress/progress_screen.dart';
import '../settings/settings_screen.dart';
import '../tables/providers.dart' show isInPipModeProvider;
import '../tables/tables_screen.dart';
import '../timer/pip_content.dart';
import '../timer/pip_controller.dart';
import '../timer/timer_screen.dart';
import 'nav_provider.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navIndexProvider);
    final l10n = AppLocalizations.of(context)!;
    final isInPip = ref.watch(isInPipModeProvider);

    // PipController must stay mounted regardless of which tab is selected
    // or whether we're currently in PiP — a hold can be running in the
    // background while another tab is open, and it must keep telling
    // native whether entering/staying in PiP is allowed.
    if (isInPip) {
      return const Scaffold(
        backgroundColor: oledBlack,
        body: Stack(children: [PipContent(), PipController()]),
      );
    }

    const bodies = <Widget>[
      TimerScreen(),
      TablesScreen(),
      ProgressScreen(),
      SettingsScreen(),
    ];

    return Scaffold(
      body: Stack(children: [bodies[selectedIndex], const PipController()]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) =>
            ref.read(navIndexProvider.notifier).state = index,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.timer_outlined),
            selectedIcon: const Icon(Icons.timer),
            label: l10n.navTimer,
          ),
          NavigationDestination(
            icon: const Icon(Icons.grid_view_outlined),
            selectedIcon: const Icon(Icons.grid_view),
            label: l10n.navTables,
          ),
          NavigationDestination(
            icon: const Icon(Icons.show_chart_outlined),
            selectedIcon: const Icon(Icons.show_chart),
            label: l10n.navProgress,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}
