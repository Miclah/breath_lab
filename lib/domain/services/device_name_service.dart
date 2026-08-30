import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';

/// Best-effort human-readable name for this device, used to seed the
/// editable "device name" setting the first time it's read. Returns null
/// if the platform gave nothing usable, leaving the caller to supply a
/// (localized) fallback.
Future<String?> suggestedDeviceName() async {
  if (Platform.isAndroid) {
    final info = await DeviceInfoPlugin().androidInfo;
    final model = info.model.trim();
    return model.isEmpty ? null : model;
  }
  final host = Platform.localHostname.trim();
  return host.isEmpty ? null : host;
}
