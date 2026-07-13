import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/holds_repository.dart';
import '../../data/repositories/table_sessions_repository.dart';
import '../../domain/services/stats_service.dart';

/// The single longest max hold ever recorded.
final allTimePbProvider = Provider<Duration?>((ref) {
  final holds = ref.watch(allHoldsProvider).valueOrNull ?? const [];
  return StatsService.allTimePB(holds);
});

/// Average max hold duration over the last 30 days.
final avg30dProvider = Provider<Duration?>((ref) {
  final holds = ref.watch(allHoldsProvider).valueOrNull ?? const [];
  return StatsService.averageWithinDays(holds, 30);
});

/// Consecutive training days ending today (or yesterday).
final currentStreakProvider = Provider<int>((ref) {
  final holds = ref.watch(allHoldsProvider).valueOrNull ?? const [];
  final tables = ref.watch(allTableSessionsProvider).valueOrNull ?? const [];
  return StatsService.currentStreak(holds, tables);
});
