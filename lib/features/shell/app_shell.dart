import 'package:flutter/material.dart' hide Durations;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/settings_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import '../progress/progress_screen.dart';
import '../settings/settings_screen.dart';
import '../tables/providers.dart' show isInPipModeProvider;
import '../tables/tables_screen.dart';
import '../timer/ambient_controllers.dart';
import '../timer/oled_hold_view.dart';
import '../timer/pip_content.dart';
import '../timer/providers.dart' show timerProvider;
import '../timer/timer_screen.dart';
import 'nav_provider.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navIndexProvider);
    final l10n = AppLocalizations.of(context)!;
    final isInPip = ref.watch(isInPipModeProvider);
    final isHolding = ref.watch(timerProvider).isHolding;
    final oledHoldEnabled =
        ref.watch(ambientOledHoldEnabledProvider).valueOrNull ?? false;
    final oledHoldActive = isHolding && oledHoldEnabled;
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    // AmbientControllers must stay mounted regardless of which tab is
    // selected or which of these modes is currently active — a hold can be
    // running in the background while another tab is open, or while the
    // OLED screen (which replaces this whole tab) or PiP overlay is shown,
    // and all of them need to keep reacting to the holding→done transition
    // even after their own visual overlay unmounts.
    if (isInPip) {
      return const Scaffold(
        backgroundColor: oledBlack,
        body: Stack(children: [PipContent(), AmbientControllers()]),
      );
    }

    const bodies = <Widget>[
      TimerScreen(),
      TablesScreen(),
      ProgressScreen(),
      SettingsScreen(),
    ];

    void onDestinationSelected(int index) =>
        ref.read(navIndexProvider.notifier).state = index;

    // IndexedStack rather than bodies[selectedIndex]: the latter tears the
    // outgoing tab down, so scroll position, history filters and chart
    // range were all lost on every tab switch. Inactive tabs stay mounted,
    // so they must be muted: without ExcludeFocus the Timer tab's autofocus
    // Focus would keep swallowing keystrokes meant for Settings' text
    // field, and without TickerMode their animations would keep running.
    final tabStack = IndexedStack(
      index: selectedIndex,
      children: [
        for (final (i, body) in bodies.indexed)
          ExcludeFocus(
            excluding: i != selectedIndex,
            child: TickerMode(enabled: i == selectedIndex, child: body),
          ),
      ],
    );

    // Crossfade between the OLED hold screen and the normal shell, per
    // Design Additions §4 — 200ms, entering and leaving the hold.
    final mainContent = oledHoldActive
        ? const OledHoldView(key: ValueKey('oled'))
        : Scaffold(
            key: const ValueKey('normal'),
            // A bottom NavigationBar is a mobile convention that eats
            // vertical space and, on a tall desktop window, can end up
            // under the taskbar. Swap to a side NavigationRail past the
            // same width breakpoint used elsewhere in the app.
            body: isDesktop
                ? Row(
                    children: [
                      NavigationRail(
                        selectedIndex: selectedIndex,
                        onDestinationSelected: onDestinationSelected,
                        labelType: NavigationRailLabelType.all,
                        destinations: [
                          NavigationRailDestination(
                            icon: const Icon(Icons.timer_outlined),
                            selectedIcon: const Icon(Icons.timer),
                            label: Text(l10n.navTimer),
                          ),
                          NavigationRailDestination(
                            icon: const Icon(Icons.grid_view_outlined),
                            selectedIcon: const Icon(Icons.grid_view),
                            label: Text(l10n.navTables),
                          ),
                          NavigationRailDestination(
                            icon: const Icon(Icons.show_chart_outlined),
                            selectedIcon: const Icon(Icons.show_chart),
                            label: Text(l10n.navProgress),
                          ),
                          NavigationRailDestination(
                            icon: const Icon(Icons.settings_outlined),
                            selectedIcon: const Icon(Icons.settings),
                            label: Text(l10n.navSettings),
                          ),
                        ],
                      ),
                      const VerticalDivider(width: 1),
                      Expanded(child: tabStack),
                    ],
                  )
                : tabStack,
            bottomNavigationBar: isDesktop
                ? null
                : NavigationBar(
                    selectedIndex: selectedIndex,
                    onDestinationSelected: onDestinationSelected,
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

    return Stack(
      children: [
        AnimatedSwitcher(duration: Durations.normal, child: mainContent),
        const AmbientControllers(),
      ],
    );
  }
}
