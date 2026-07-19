import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/services/notification_service.dart';
import '../../l10n/app_localizations.dart';
import '../tables/providers.dart' show notificationServiceProvider;
import 'providers.dart';

String _fmt(Duration d) {
  final m = d.inMinutes.toString().padLeft(2, '0');
  final s = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

/// Invisible widget that shows/updates/dismisses the persistent Android
/// notification during an active hold, per PRD §A2. Mount once in the
/// Timer screen's widget tree — renders nothing.
class HoldNotificationListener extends ConsumerStatefulWidget {
  const HoldNotificationListener({super.key});

  @override
  ConsumerState<HoldNotificationListener> createState() =>
      _HoldNotificationListenerState();
}

class _HoldNotificationListenerState
    extends ConsumerState<HoldNotificationListener> {
  int _lastShownSecond = -1;
  bool _wasHolding = false;

  @override
  void initState() {
    super.initState();
    ref.read(notificationServiceProvider).onAction = _handleAction;
  }

  void _handleAction(HoldNotificationAction action) {
    final notifier = ref.read(timerProvider.notifier);
    switch (action) {
      case HoldNotificationAction.stop:
        notifier.stop();
      case HoldNotificationAction.markContraction:
        notifier.markContraction();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(timerProvider);
    final service = ref.read(notificationServiceProvider);

    if (!state.isHolding) {
      if (_wasHolding) service.dismiss();
      _wasHolding = false;
      _lastShownSecond = -1;
      return const SizedBox.shrink();
    }

    if (!_wasHolding) {
      _wasHolding = true;
      service.requestPermission();
    }

    final second = state.holdElapsed.inSeconds;
    if (second != _lastShownSecond) {
      _lastShownSecond = second;
      final hasContraction = state.contractionTime != null;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        service.show(
          title: _fmt(state.holdElapsed),
          body: l10n.notificationMaxHoldBody,
          stopLabel: l10n.timerStopButton,
          markContractionLabel: hasContraction
              ? null
              : l10n.notificationMarkContractionAction,
        );
      });
    }

    return const SizedBox.shrink();
  }
}
