import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/table_session.dart';

/// Which table (CO₂ or O₂) is currently shown on the Tables screen.
final selectedTableTypeProvider = StateProvider<TableType>(
  (ref) => TableType.co2,
);
