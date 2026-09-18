import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  // Fire-and-forget: not on the critical path for anything the app shows,
  // and cheap once a day's worth of tombstones is all there ever is to
  // find past the retention window.
  unawaited(db.purgeOldTombstones());
  return db;
});
