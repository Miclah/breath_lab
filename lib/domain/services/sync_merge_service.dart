import '../models/sync_payload.dart';

/// How many rows changed on the *local* side as a result of a merge —
/// drives the "Added 24 holds, 2 sessions. Updated 2 holds." summary.
class MergeCounts {
  const MergeCounts({
    this.holdsAdded = 0,
    this.holdsUpdated = 0,
    this.sessionsAdded = 0,
    this.sessionsUpdated = 0,
    this.imstAdded = 0,
    this.imstUpdated = 0,
    this.tagsAdded = 0,
    this.tagsUpdated = 0,
  });

  final int holdsAdded;
  final int holdsUpdated;
  final int sessionsAdded;
  final int sessionsUpdated;
  final int imstAdded;
  final int imstUpdated;
  final int tagsAdded;
  final int tagsUpdated;
}

class MergeResult {
  const MergeResult({
    required this.holds,
    required this.tableSessions,
    required this.imstSessions,
    required this.tags,
    required this.counts,
  });

  final List<SyncHoldRecord> holds;
  final List<SyncTableSessionRecord> tableSessions;
  final List<SyncImstSessionRecord> imstSessions;
  final List<SyncTagRecord> tags;
  final MergeCounts counts;
}

class _MergeOutcome<T> {
  const _MergeOutcome(this.merged, this.added, this.updated);

  final List<T> merged;
  final int added;
  final int updated;
}

/// Set-union, last-write-wins merge of two devices' full state. See
/// "Merge rules" in `docs/phases/PHASE_2A_sync.md` — no CRDTs, no vector
/// clocks: every syncable row already carries `id`, `updated_at`, and
/// (for holds/table_sessions) `device_id`, which is enough.
///
/// A pure function: no database, no I/O, fully unit-testable.
class SyncMergeService {
  const SyncMergeService._();

  static MergeResult merge({
    required SyncPayload local,
    required SyncPayload remote,
  }) {
    final holds = _mergeById<SyncHoldRecord>(
      local: local.holds,
      remote: remote.holds,
      id: (h) => h.id,
      updatedAt: (h) => h.updatedAt,
      // Tag ids live on the hold record itself, so the winning row's tag
      // set replaces the local one for free — no separate hold_tags merge.
      tiebreak: (h) => h.deviceId,
    );
    final sessions = _mergeById<SyncTableSessionRecord>(
      local: local.tableSessions,
      remote: remote.tableSessions,
      id: (s) => s.id,
      updatedAt: (s) => s.updatedAt,
      tiebreak: (s) => s.deviceId,
    );
    final imst = _mergeById<SyncImstSessionRecord>(
      local: local.imstSessions,
      remote: remote.imstSessions,
      id: (s) => s.id,
      updatedAt: (s) => s.updatedAt,
      tiebreak: (s) => s.deviceId,
    );
    final tags = _mergeById<SyncTagRecord>(
      local: local.tags,
      remote: remote.tags,
      id: (t) => t.id,
      updatedAt: (t) => t.updatedAt,
      // The `tags` table has no device_id column. Using `id` here would be
      // degenerate — on a same-id tie it compares equal to itself, so
      // neither side would ever defer to the other. labelKey is the only
      // other field both sides have, so it stands in as the tiebreak key.
      tiebreak: (t) => t.labelKey,
    );

    return MergeResult(
      holds: holds.merged,
      tableSessions: sessions.merged,
      imstSessions: imst.merged,
      tags: tags.merged,
      counts: MergeCounts(
        holdsAdded: holds.added,
        holdsUpdated: holds.updated,
        sessionsAdded: sessions.added,
        sessionsUpdated: sessions.updated,
        imstAdded: imst.added,
        imstUpdated: imst.updated,
        tagsAdded: tags.added,
        tagsUpdated: tags.updated,
      ),
    );
  }

  /// Unknown id → insert. Known id → keep the row with the higher
  /// `updatedAt`; tie → keep the higher [tiebreak] value. Comparing both
  /// sides with the same rule means both devices independently converge
  /// on the same winner, regardless of which one is "local" here.
  static _MergeOutcome<T> _mergeById<T>({
    required List<T> local,
    required List<T> remote,
    required String Function(T) id,
    required int Function(T) updatedAt,
    required String Function(T) tiebreak,
  }) {
    final byId = <String, T>{for (final e in local) id(e): e};
    var added = 0;
    var updated = 0;

    for (final incoming in remote) {
      final key = id(incoming);
      final existing = byId[key];
      if (existing == null) {
        byId[key] = incoming;
        added++;
        continue;
      }
      final incomingAt = updatedAt(incoming);
      final existingAt = updatedAt(existing);
      final incomingWins =
          incomingAt > existingAt ||
          (incomingAt == existingAt &&
              tiebreak(incoming).compareTo(tiebreak(existing)) > 0);
      if (incomingWins) {
        byId[key] = incoming;
        updated++;
      }
    }

    return _MergeOutcome(byId.values.toList(), added, updated);
  }
}
