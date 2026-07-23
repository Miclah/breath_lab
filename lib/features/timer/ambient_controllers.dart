import 'package:flutter/widgets.dart';

import 'callout_listener.dart';
import 'hold_notification_listener.dart';
import 'notification_permission_banner_controller.dart';
import 'oled_hold_view.dart';
import 'past_pb_warning_controller.dart';
import 'pip_controller.dart';

/// Bundles every invisible controller that must keep reacting to the timer
/// state regardless of which screen is actually visible — the normal shell,
/// the OLED hold screen, or the PiP overlay. A hold can be running while
/// the user is on a different tab, in PiP, or looking at the OLED screen
/// (which replaces the whole Timer tab), so none of these can live inside
/// [TimerScreen] itself. Mount once, at the [AppShell] level.
class AmbientControllers extends StatelessWidget {
  const AmbientControllers({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        CalloutListener(),
        HoldNotificationListener(),
        NotificationPermissionBannerController(),
        PastPbWarningController(),
        PipController(),
        OledBrightnessController(),
      ],
    );
  }
}
