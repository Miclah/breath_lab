import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../db/app_database.dart' as db;
import '../db/database_provider.dart';
import '../../domain/models/table_session.dart';
import 'device_id_provider.dart';

class TableSessionsRepository {
  TableSessionsRepository(this._db, this._deviceId);

  final db.AppDatabase _db;
  final String _deviceId;
  static const _uuid = Uuid();

  String newId() => _uuid.v4();

  Future<void> save(TableSession session) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _db
        .into(_db.tableSessions)
        .insertOnConflictUpdate(
          db.TableSessionsCompanion(
            id: Value(session.id),
            createdAt: Value(session.createdAt.millisecondsSinceEpoch),
            updatedAt: Value(now),
            deviceId: Value(_deviceId),
            type: Value(session.type.dbValue),
            basedOnMaxMs: Value(session.basedOnMaxMs),
            roundsTotal: Value(session.roundsTotal),
            roundsCompleted: Value(session.roundsCompleted),
            roundDetails: Value(
              TableSession.encodeRoundDetails(session.roundDetails),
            ),
            deleted: const Value(0),
          ),
        );
  }

  Future<List<TableSession>> getAll() async {
    final rows =
        await (_db.select(_db.tableSessions)
              ..where((t) => t.deleted.equals(0))
              ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
            .get();
    return rows.map(_fromRow).toList();
  }

  TableSession _fromRow(db.TableSession row) {
    return TableSession(
      id: row.id,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(row.updatedAt),
      deviceId: row.deviceId,
      type: TableType.fromDb(row.type),
      basedOnMaxMs: row.basedOnMaxMs,
      roundsTotal: row.roundsTotal,
      roundsCompleted: row.roundsCompleted,
      roundDetails: TableSession.decodeRoundDetails(row.roundDetails),
    );
  }
}

final tableSessionsRepositoryProvider = FutureProvider<TableSessionsRepository>(
  (ref) async {
    final database = ref.watch(databaseProvider);
    final deviceId = await ref.watch(deviceIdProvider.future);
    return TableSessionsRepository(database, deviceId);
  },
);

/// All non-deleted table sessions, newest first.
final allTableSessionsProvider = FutureProvider<List<TableSession>>((
  ref,
) async {
  final repo = await ref.watch(tableSessionsRepositoryProvider.future);
  return repo.getAll();
});
