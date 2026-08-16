import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/settings_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/format_duration.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import '../tables/providers.dart' show brightnessServiceProvider;
import 'providers.dart';

/// OLED-friendly hold screen, per Design Additions §4: pure black, enlarged
/// mono timer, no ring decoration, borderless Stop. Uses the dark color
/// scheme regardless of app theme — same reasoning as [PipContent].
class OledHoldView extends ConsumerStatefulWidget {
  const OledHoldView({super.key});

  @override
  ConsumerState<OledHoldView> createState() => _OledHoldViewState();
}

class _OledHoldViewState extends ConsumerState<OledHoldView> {
  @override
  void initState() {
    super.initState();
    // The whole point of this screen is an unlit OLED panel — system status
    // bar and nav bar icons defeat that and are needless glow next to
    // closed or dazzled eyes.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = BreathLabColors.dark;
    final elapsed = ref.watch(timerProvider).holdElapsed;
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: oledBlack,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Center(
                child: Text(
                  formatMmSs(elapsed),
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: isDesktop ? 128 : 96,
                    fontWeight: FontWeight.w500,
                    color: c.primary,
                  ),
                ),
              ),
            ),
            Text(
              l10n.timerStateLabelHold,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: c.textSecondary),
            ),
            const SizedBox(height: Spacing.sm),
            // The whole bottom third is the Stop target, not just the text
            // — at a dazzled glance or with eyes closed, a 56dp button is
            // hard to land on.
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => ref.read(timerProvider.notifier).stop(),
                child: Center(
                  child: Text(
                    l10n.timerStopButton,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: c.danger),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Invisible widget that dims the screen while the OLED hold screen is
/// active (per the brightness override setting) and restores it once the
/// hold ends. Mount unconditionally, alongside [OledHoldView]'s toggle in
/// the shell, so it can react to the holding→done transition.
class OledBrightnessController extends ConsumerStatefulWidget {
  const OledBrightnessController({super.key});

  @override
  ConsumerState<OledBrightnessController> createState() =>
      _OledBrightnessControllerState();
}

class _OledBrightnessControllerState
    extends ConsumerState<OledBrightnessController> {
  bool? _lastDimmed;

  @override
  Widget build(BuildContext context) {
    final isHolding = ref.watch(timerProvider).isHolding;
    final oledEnabled =
        ref.watch(ambientOledHoldEnabledProvider).valueOrNull ?? false;
    final brightnessOverride =
        ref.watch(ambientBrightnessOverrideProvider).valueOrNull ??
        BrightnessOverride.current;

    final shouldDim =
        isHolding &&
        oledEnabled &&
        brightnessOverride == BrightnessOverride.low;

    if (shouldDim != _lastDimmed) {
      _lastDimmed = shouldDim;
      final service = ref.read(brightnessServiceProvider);
      if (shouldDim) {
        service.setLow();
      } else {
        service.restore();
      }
    }

    return const SizedBox.shrink();
  }
}
