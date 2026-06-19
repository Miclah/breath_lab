import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import 'nav_provider.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navIndexProvider);
    final l10n = AppLocalizations.of(context)!;

    final bodies = <Widget>[
      Center(child: Text(l10n.navTimer)),
      Center(child: Text(l10n.navTables)),
      Center(child: Text(l10n.navProgress)),
      Center(child: Text(l10n.navSettings)),
    ];

    return Scaffold(
      body: bodies[selectedIndex],
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
