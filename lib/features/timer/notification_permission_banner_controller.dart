import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/global_messenger.dart';
import '../tables/providers.dart'
    show
        foregroundServiceDisabledProvider,
        notificationPermissionDeniedProvider;
import 'providers.dart';

/// Invisible widget that shows an in-app banner during a hold when the
/// Android notification permission was denied, or the OS refused to start
/// the foreground service (e.g. battery optimization), per PRD §11.
/// Mounted once at the shell level (not inside [TimerScreen]) so it still
/// works while the OLED hold screen or PiP has replaced the timer screen
/// entirely.
class NotificationPermissionBannerController extends ConsumerWidget {
  const NotificationPermissionBannerController({super.key});

  void _refresh(WidgetRef ref, AppLocalizations l10n) {
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger == null) return;
    final isHolding = ref.read(timerProvider).isHolding;
    final permissionDenied = ref.read(notificationPermissionDeniedProvider);
    final serviceDisabled = ref.read(foregroundServiceDisabledProvider);

    if (!isHolding || (!permissionDenied && !serviceDisabled)) {
      messenger.clearMaterialBanners();
      return;
    }

    // Permission takes priority — fixing it is likely to also fix the
    // foreground-service failure, which is often a downstream symptom.
    final message = permissionDenied
        ? l10n.notificationPermissionDeniedBanner
        : l10n.foregroundServiceDisabledBanner;

    messenger
      ..clearMaterialBanners()
      ..showMaterialBanner(
        MaterialBanner(
          content: Text(message),
          actions: [
            TextButton(
              onPressed: messenger.clearMaterialBanners,
              child: Text(l10n.bannerDismissAction),
            ),
          ],
        ),
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    ref.listen(notificationPermissionDeniedProvider, (_, _) {
      _refresh(ref, l10n);
    });
    ref.listen(foregroundServiceDisabledProvider, (_, _) {
      _refresh(ref, l10n);
    });
    ref.listen(timerProvider, (previous, next) {
      if (previous?.isHolding == true && !next.isHolding) {
        scaffoldMessengerKey.currentState?.clearMaterialBanners();
      }
    });

    return const SizedBox.shrink();
  }
}
