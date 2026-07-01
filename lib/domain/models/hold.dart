enum HoldType {
  max,
  co2,
  o2,
  walk;

  String get dbValue => switch (this) {
    HoldType.max => 'max',
    HoldType.co2 => 'co2',
    HoldType.o2 => 'o2',
    HoldType.walk => 'walk',
  };

  static HoldType fromDb(String value) => switch (value) {
    'co2' => HoldType.co2,
    'o2' => HoldType.o2,
    'walk' => HoldType.walk,
    _ => HoldType.max,
  };
}

enum LungVolume {
  full,
  frc,
  empty;

  String get dbValue => switch (this) {
    LungVolume.full => 'full',
    LungVolume.frc => 'frc',
    LungVolume.empty => 'empty',
  };

  static LungVolume fromDb(String value) => switch (value) {
    'frc' => LungVolume.frc,
    'empty' => LungVolume.empty,
    _ => LungVolume.full,
  };
}

enum PrepMode {
  none,
  threeSeconds,
  short,
  full;

  String get dbValue => switch (this) {
    PrepMode.none => 'none',
    PrepMode.threeSeconds => '3s',
    PrepMode.short => 'short',
    PrepMode.full => 'full',
  };

  static PrepMode? fromDb(String? value) => switch (value) {
    'none' => PrepMode.none,
    '3s' => PrepMode.threeSeconds,
    'short' => PrepMode.short,
    'full' => PrepMode.full,
    _ => null,
  };
}

class Hold {
  const Hold({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.deviceId,
    required this.duration,
    this.contractionTime,
    required this.type,
    required this.lungVolume,
    this.prepMode,
    this.notes,
    required this.isPb,
    this.rating,
  });

  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String deviceId;
  final Duration duration;
  final Duration? contractionTime;
  final HoldType type;
  final LungVolume lungVolume;
  final PrepMode? prepMode;
  final String? notes;
  final bool isPb;
  final int? rating;

  Hold copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? deviceId,
    Duration? duration,
    Duration? contractionTime,
    HoldType? type,
    LungVolume? lungVolume,
    PrepMode? prepMode,
    String? notes,
    bool? isPb,
    int? rating,
  }) {
    return Hold(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deviceId: deviceId ?? this.deviceId,
      duration: duration ?? this.duration,
      contractionTime: contractionTime ?? this.contractionTime,
      type: type ?? this.type,
      lungVolume: lungVolume ?? this.lungVolume,
      prepMode: prepMode ?? this.prepMode,
      notes: notes ?? this.notes,
      isPb: isPb ?? this.isPb,
      rating: rating ?? this.rating,
    );
  }
}
