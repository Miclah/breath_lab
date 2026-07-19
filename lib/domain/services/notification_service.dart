import 'dart:io' show Platform;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

enum HoldNotificationAction { stop, markContraction }

/// Persistent notification with a live timer during an active hold, backed
/// by a real Android foreground service (PRD §A2). Every method is a no-op
/// on non-Android platforms — flutter_local_notifications has no service
/// implementation there.
class NotificationService {
  NotificationService() : _plugin = FlutterLocalNotificationsPlugin();

  static const _notificationId = 1;
  static const _channelId = 'active_hold';
  static const _channelName = 'Active hold';

  final FlutterLocalNotificationsPlugin _plugin;

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  /// Called when the user taps Stop or Mark contraction on the
  /// notification. Set by the widget that owns the timer.
  void Function(HoldNotificationAction action)? onAction;

  Future<void> initialize() async {
    if (!Platform.isAndroid) return;
    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: _handleResponse,
    );
  }

  void _handleResponse(NotificationResponse response) {
    final action = switch (response.actionId) {
      'stop' => HoldNotificationAction.stop,
      'mark_contraction' => HoldNotificationAction.markContraction,
      _ => null,
    };
    if (action != null) onAction?.call(action);
  }

  /// Requests the Android 13+ POST_NOTIFICATIONS permission. Returns true
  /// if granted; already-granted or not-required cases also resolve true.
  /// Safe to call every hold — Android only prompts once.
  Future<bool> requestPermission() async {
    if (!Platform.isAndroid) return true;
    return await _android?.requestNotificationsPermission() ?? false;
  }

  /// Shows or updates the live-timer notification. Safe to call
  /// repeatedly — flutter_local_notifications updates the same
  /// foreground-service notification in place.
  Future<void> show({
    required String title,
    required String body,
    required String stopLabel,
    String? markContractionLabel,
  }) async {
    if (!Platform.isAndroid) return;
    await _android?.startForegroundService(
      _notificationId,
      title,
      body,
      notificationDetails: AndroidNotificationDetails(
        _channelId,
        _channelName,
        ongoing: true,
        onlyAlertOnce: true,
        category: AndroidNotificationCategory.stopwatch,
        priority: Priority.low,
        importance: Importance.low,
        actions: [
          // showsUserInterface: true routes the tap through the foreground
          // onDidReceiveNotificationResponse callback (bringing the app to
          // front). Without it, Android always dispatches through a
          // background isolate instead, even while the app is foregrounded.
          AndroidNotificationAction(
            'stop',
            stopLabel,
            showsUserInterface: true,
            cancelNotification: false,
          ),
          if (markContractionLabel != null)
            AndroidNotificationAction(
              'mark_contraction',
              markContractionLabel,
              showsUserInterface: true,
              cancelNotification: false,
            ),
        ],
      ),
      foregroundServiceTypes: const {
        AndroidServiceForegroundType.foregroundServiceTypeSpecialUse,
      },
    );
  }

  /// Dismisses the notification and stops the foreground service.
  Future<void> dismiss() async {
    if (!Platform.isAndroid) return;
    await _android?.stopForegroundService();
  }
}
