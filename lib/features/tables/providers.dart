import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/table_session.dart';
import '../../domain/services/audio_service.dart';
import '../../domain/services/haptics_service.dart';

/// Which table (CO₂ or O₂) is currently shown on the Tables screen.
final selectedTableTypeProvider = StateProvider<TableType>(
  (ref) => TableType.co2,
);

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(service.dispose);
  return service;
});

final hapticsServiceProvider = Provider<HapticsService>(
  (ref) => HapticsService(),
);
