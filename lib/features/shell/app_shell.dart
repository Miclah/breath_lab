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
import '../timer/oled_hold_view.dart';
import '../timer/pip_content.dart';
import '../timer/pip_controller.dart';
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

    // PipController/OledBrightnessController must stay mounted regardless
    // of which tab is selected or which of these modes is currently active
    // — a hold can be running in the background while another tab is
    // open, and both need to keep reacting to the holding→done transition
    // (dismiss PiP eligibility, restore brightness) even after their own
    // visual overlay unmounts.
    if (isInPip) {
      return const Scaffold(
        backgroundColor: oledBlack,
        body: Stack(
          children: [PipContent(), PipController(), OledBrightnessController()],
        ),
      );
    }

    const bodies = <Widget>[
      TimerScreen(),
      TablesScreen(),
      ProgressScreen(),
      SettingsScreen(),
    ];

    // Crossfade between the OLED hold screen and the normal shell, per
    // Design Additions §4 — 200ms, entering and leaving the hold.
    final mainContent = oledHoldActive
        ? const OledHoldView(key: ValueKey('oled'))
        : Scaffold(
            key: const ValueKey('normal'),
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

    return Stack(
      children: [
        AnimatedSwitcher(duration: Durations.normal, child: mainContent),
        const PipController(),
        const OledBrightnessController(),
      ],
    );
  }
}
