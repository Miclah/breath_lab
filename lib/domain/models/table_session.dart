import 'dart:convert';

enum TableType {
  co2,
  o2;

  String get dbValue => switch (this) {
    TableType.co2 => 'co2',
    TableType.o2 => 'o2',
  };

  static TableType fromDb(String value) => switch (value) {
    'o2' => TableType.o2,
    _ => TableType.co2,
  };
}

class TableRoundDetail {
  const TableRoundDetail({
    required this.holdMs,
    required this.restMs,
    required this.completed,
  });

  final int holdMs;
  final int restMs;
  final bool completed;

  Map<String, dynamic> toJson() => {
    'holdMs': holdMs,
    'restMs': restMs,
    'completed': completed,
  };

  factory TableRoundDetail.fromJson(Map<String, dynamic> json) {
    return TableRoundDetail(
      holdMs: json['holdMs'] as int,
      restMs: json['restMs'] as int,
      completed: json['completed'] as bool,
    );
  }
}

class TableSession {
  const TableSession({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.deviceId,
    required this.type,
    required this.basedOnMaxMs,
    required this.roundsTotal,
    required this.roundsCompleted,
    required this.roundDetails,
  });

  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String deviceId;
  final TableType type;
  final int basedOnMaxMs;
  final int roundsTotal;
  final int roundsCompleted;
  final List<TableRoundDetail> roundDetails;

  static List<TableRoundDetail> decodeRoundDetails(String json) {
    return (jsonDecode(json) as List)
        .map((e) => TableRoundDetail.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static String encodeRoundDetails(List<TableRoundDetail> details) {
    return jsonEncode(details.map((d) => d.toJson()).toList());
  }
}
