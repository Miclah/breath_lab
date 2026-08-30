/// A logged inspiratory-muscle-strength-training session.
///
/// IMST is tracked as its own entity rather than a [Hold][] row: Craighead's
/// protocol is defined by breath count and resistance, not by a hold time, and
/// the extra fields (device, level, optional PImax) have no home on a hold.
/// It still carries the full sync column set from `CLAUDE.md` rule 5 so the
/// merge engine treats it exactly like a hold or a table session.
///
/// [Hold]: hold.dart
class ImstSession {
  const ImstSession({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.deviceId,
    required this.breaths,
    this.deviceName,
    this.deviceLevel,
    this.pimaxCmH2O,
    this.percentPimax,
    this.duration,
  });

  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String deviceId;

  /// Resisted breaths completed this session. Craighead's target is 30.
  final int breaths;

  /// Free-text trainer name, e.g. "POWERbreathe Plus". Optional.
  final String? deviceName;

  /// The numbered resistance position the user actually set on the device.
  /// A dial position, not a pressure — deliberately not converted to % PImax.
  final int? deviceLevel;

  /// Maximal inspiratory pressure in cmH₂O, for the minority who have a
  /// measured figure. Optional and never inferred from [deviceLevel].
  final int? pimaxCmH2O;

  /// Session load as a percentage of [pimaxCmH2O], when both are known.
  final int? percentPimax;

  /// Wall-clock length of the session, when recorded.
  final Duration? duration;

  ImstSession copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? deviceId,
    int? breaths,
    String? deviceName,
    int? deviceLevel,
    int? pimaxCmH2O,
    int? percentPimax,
    Duration? duration,
  }) {
    return ImstSession(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deviceId: deviceId ?? this.deviceId,
      breaths: breaths ?? this.breaths,
      deviceName: deviceName ?? this.deviceName,
      deviceLevel: deviceLevel ?? this.deviceLevel,
      pimaxCmH2O: pimaxCmH2O ?? this.pimaxCmH2O,
      percentPimax: percentPimax ?? this.percentPimax,
      duration: duration ?? this.duration,
    );
  }
}
