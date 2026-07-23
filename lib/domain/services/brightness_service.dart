import 'package:screen_brightness/screen_brightness.dart';

/// Dims the screen during the OLED hold screen, per Design Additions §4.
/// Uses application-scoped brightness (not system-wide) so it doesn't
/// require any extra permission and never affects the rest of the device.
class BrightnessService {
  static const _lowBrightness = 0.15;

  Future<void> setLow() =>
      ScreenBrightness.instance.setApplicationScreenBrightness(_lowBrightness);

  Future<void> restore() =>
      ScreenBrightness.instance.resetApplicationScreenBrightness();
}
