import 'package:wakelock_plus/wakelock_plus.dart';

/// Keeps the screen awake during an active hold, per PRD §A4 — released
/// again once the hold is saved or discarded.
class WakelockService {
  Future<void> enable() => WakelockPlus.enable();

  Future<void> disable() => WakelockPlus.disable();
}
