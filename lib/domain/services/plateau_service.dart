import '../models/hold.dart';

/// The result of the plateau check — deliberately just three facts, so the
/// card can show the two figures it is comparing.
class PlateauStatus {
  const PlateauStatus({
    required this.plateaued,
    this.recentBest,
    this.previousBest,
  });

  static const none = PlateauStatus(plateaued: false);

  final bool plateaued;

  /// Best Full-lung max hold in the last 28 days.
  final Duration? recentBest;

  /// Best Full-lung max hold in the 28 days before that.
  final Duration? previousBest;
}

/// Plateau detection, `RESEARCH_ALIGNMENT.md` §3.2. Deliberately a single
/// comparison and no modelling:
///
/// > If the best Full-lung max hold of the last 28 days does not exceed the
/// > best of the preceding 28 days, the user has plateaued.
///
/// It only fires when there is a hold in *both* windows — you cannot have
/// plateaued against nothing — and it never blocks training, only surfaces
/// the research's own advice.
class PlateauService {
  const PlateauService._();

  static const windowDays = 28;

  static DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  static PlateauStatus detect(List<Hold> holds, {DateTime? now}) {
    final today = _dateOnly(now ?? DateTime.now());
    final recentStart = today.subtract(const Duration(days: windowDays));
    final previousStart = today.subtract(const Duration(days: windowDays * 2));

    Duration? recentBest;
    Duration? previousBest;
    for (final hold in holds) {
      if (hold.type != HoldType.max || hold.lungVolume != LungVolume.full) {
        continue;
      }
      final day = _dateOnly(hold.createdAt);
      if (day.isAfter(today)) continue;
      if (!day.isBefore(recentStart)) {
        if (recentBest == null || hold.duration > recentBest) {
          recentBest = hold.duration;
        }
      } else if (!day.isBefore(previousStart)) {
        if (previousBest == null || hold.duration > previousBest) {
          previousBest = hold.duration;
        }
      }
    }

    if (recentBest == null || previousBest == null) return PlateauStatus.none;
    return PlateauStatus(
      plateaued: recentBest <= previousBest,
      recentBest: recentBest,
      previousBest: previousBest,
    );
  }
}
