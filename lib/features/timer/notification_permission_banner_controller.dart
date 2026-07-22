import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/global_messenger.dart';
import '../tables/providers.dart' show notificationPermissionDeniedProvider;
import 'providers.dart';

/// Invisible widget that shows an in-app banner during a hold when the
/// Android notification permission was denied, per PRD §11. Mounted once
/// at the shell level (not inside [TimerScreen]) so it still works while
/// the OLED hold screen or PiP has replaced the timer screen entirely.
class NotificationPermissionBannerController extends ConsumerWidget {
  const NotificationPermissionBannerController({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    ref.listen(notificationPermissionDeniedProvider, (_, denied) {
      final isHolding = ref.read(timerProvider).isHolding;
      final messenger = scaffoldMessengerKey.currentState;
      if (messenger == null) return;
      if (denied && isHolding) {
        messenger
          ..clearMaterialBanners()
          ..showMaterialBanner(
            MaterialBanner(
              content: Text(l10n.notificationPermissionDeniedBanner),
              actions: [
                TextButton(
                  onPressed: messenger.clearMaterialBanners,
                  child: Text(l10n.bannerDismissAction),
                ),
              ],
            ),
          );
      } else {
        messenger.clearMaterialBanners();
      }
    });

    ref.listen(timerProvider, (previous, next) {
      if (previous?.isHolding == true && !next.isHolding) {
        scaffoldMessengerKey.currentState?.clearMaterialBanners();
      }
    });

    return const SizedBox.shrink();
  }
}
