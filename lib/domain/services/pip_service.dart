import 'dart:io' show Platform;

import 'package:flutter/services.dart';

/// Bridges to MainActivity's picture-in-picture MethodChannel (PRD §A3).
/// Every method is a no-op on non-Android platforms.
class PipService {
  PipService() : _channel = const MethodChannel('com.example.breath_lab/pip') {
    if (Platform.isAndroid) {
      _channel.setMethodCallHandler(_handleCall);
    }
  }

  final MethodChannel _channel;

  /// Called when Android reports a PiP mode change (entered or exited).
  void Function(bool isInPipMode)? onModeChanged;

  /// Tells native whether entering PiP on the next onUserLeaveHint is
  /// currently allowed (i.e. a hold is active and the ambient PiP setting
  /// is on).
  Future<void> setEnabled(bool enabled) async {
    if (!Platform.isAndroid) return;
    await _channel.invokeMethod('setEnabled', enabled);
  }

  Future<void> _handleCall(MethodCall call) async {
    if (call.method == 'modeChanged') {
      onModeChanged?.call(call.arguments as bool);
    }
  }
}
