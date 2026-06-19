import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final safetyAcknowledgedProvider = AsyncNotifierProvider<SafetyNotifier, bool>(
  SafetyNotifier.new,
);

class SafetyNotifier extends AsyncNotifier<bool> {
  static const _key = 'acknowledged_safety';

  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  Future<void> acknowledge() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
    state = const AsyncData(true);
  }
}
