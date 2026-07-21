import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/settings_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import '../tables/providers.dart' show brightnessServiceProvider;
import 'providers.dart';

String _fmtDuration(Duration d) {
  final m = d.inMinutes.toString().padLeft(2, '0');
  final s = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

/// OLED-friendly hold screen, per Design Additions §4: pure black, enlarged
/// mono timer, no ring decoration, borderless Stop. Uses the dark color
/// scheme regardless of app theme — same reasoning as [PipContent].
class OledHoldView extends ConsumerWidget {
  const OledHoldView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              child: Center(
                child: Text(
                  _fmtDuration(elapsed),
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
            const SizedBox(height: Spacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: TextButton(
                  onPressed: () => ref.read(timerProvider.notifier).stop(),
                  style: TextButton.styleFrom(foregroundColor: c.danger),
                  child: Text(l10n.timerStopButton),
                ),
              ),
            ),
            const SizedBox(height: Spacing.xl),
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
