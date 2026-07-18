import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/settings_repository.dart';
import '../../domain/models/table_session.dart';
import '../../domain/services/audio_service.dart';
import '../../domain/services/haptics_service.dart';
import '../../domain/services/tts_service.dart';

/// Which table (CO₂ or O₂) is currently shown on the Tables screen.
final selectedTableTypeProvider = StateProvider<TableType>(
  (ref) => TableType.co2,
);

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(service.dispose);

  ref.listen(soundEnabledProvider, (_, next) {
    next.whenData((enabled) => service.enabled = enabled);
  }, fireImmediately: true);
  ref.listen(soundVolumeProvider, (_, next) {
    next.whenData((percent) => service.volume = percent / 100);
  }, fireImmediately: true);

  return service;
});

final hapticsServiceProvider = Provider<HapticsService>(
  (ref) => HapticsService(),
);

final ttsServiceProvider = Provider<TtsService>((ref) {
  final service = TtsService();
  ref.onDispose(service.dispose);

  ref.listen(effectiveTtsLanguageProvider, (_, next) {
    next.whenData(service.setLanguage);
  }, fireImmediately: true);

  return service;
});
