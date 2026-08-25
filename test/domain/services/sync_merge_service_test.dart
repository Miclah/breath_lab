import 'package:flutter_test/flutter_test.dart';
import 'package:breath_lab/domain/models/sync_payload.dart';
import 'package:breath_lab/domain/services/sync_merge_service.dart';

SyncHoldRecord _hold({
  required String id,
  required int updatedAt,
  String deviceId = 'device-a',
  int createdAt = 1000,
  int durationMs = 60000,
  bool deleted = false,
  List<String> tagIds = const [],
}) {
  return SyncHoldRecord(
    id: id,
    createdAt: createdAt,
    updatedAt: updatedAt,
    deviceId: deviceId,
    durationMs: durationMs,
    type: 'max',
    lungVolume: 'full',
    isPb: false,
    deleted: deleted,
    tagIds: tagIds,
  );
}

SyncPayload _payload({
  List<SyncHoldRecord> holds = const [],
  List<SyncTableSessionRecord> tableSessions = const [],
  List<SyncTagRecord> tags = const [],
  String deviceId = 'device-a',
}) {
  return SyncPayload(
    schemaVersion: 2,
    exportedAt: 1700000000000,
    deviceId: deviceId,
    deviceName: 'Test device',
    appVersion: '1.0.0',
    holds: holds,
    tableSessions: tableSessions,
    tags: tags,
  );
}

void main() {
  group('SyncMergeService.merge', () {
    test('unions disjoint hold sets from both sides', () {
      final local = _payload(holds: [_hold(id: 'a', updatedAt: 1)]);
      final remote = _payload(holds: [_hold(id: 'b', updatedAt: 1)]);

      final result = SyncMergeService.merge(local: local, remote: remote);

      expect(result.holds.map((h) => h.id), unorderedEquals(['a', 'b']));
      expect(result.counts.holdsAdded, 1);
      expect(result.counts.holdsUpdated, 0);
    });

    test('last-write-wins keeps the row with the later updatedAt', () {
      final local = _payload(
        holds: [_hold(id: 'a', updatedAt: 1, durationMs: 1000)],
      );
      final remote = _payload(
        holds: [_hold(id: 'a', updatedAt: 2, durationMs: 2000)],
      );

      final result = SyncMergeService.merge(local: local, remote: remote);

      expect(result.holds.single.durationMs, 2000);
      expect(result.counts.holdsUpdated, 1);
      expect(result.counts.holdsAdded, 0);
    });

    test('an older remote edit does not overwrite a newer local one', () {
      final local = _payload(
        holds: [_hold(id: 'a', updatedAt: 5, durationMs: 5000)],
      );
      final remote = _payload(
        holds: [_hold(id: 'a', updatedAt: 2, durationMs: 2000)],
      );

      final result = SyncMergeService.merge(local: local, remote: remote);

      expect(result.holds.single.durationMs, 5000);
      expect(result.counts.holdsUpdated, 0);
    });

    test(
      'device_id tiebreak on equal updatedAt converges from both directions',
      () {
        final onA = _payload(
          holds: [
            _hold(id: 'a', updatedAt: 9, deviceId: 'aaa', durationMs: 1111),
          ],
        );
        final onB = _payload(
          holds: [
            _hold(id: 'a', updatedAt: 9, deviceId: 'zzz', durationMs: 2222),
          ],
        );

        final mergedOnA = SyncMergeService.merge(local: onA, remote: onB);
        final mergedOnB = SyncMergeService.merge(local: onB, remote: onA);

        expect(mergedOnA.holds.single.deviceId, 'zzz');
        expect(mergedOnB.holds.single.deviceId, 'zzz');
        expect(mergedOnA.holds.single.durationMs, 2222);
        expect(mergedOnB.holds.single.durationMs, 2222);
      },
    );

    test('a delete (deleted: true) propagates like any other newer edit', () {
      final local = _payload(
        holds: [_hold(id: 'a', updatedAt: 1, deleted: false)],
      );
      final remote = _payload(
        holds: [_hold(id: 'a', updatedAt: 2, deleted: true)],
      );

      final result = SyncMergeService.merge(local: local, remote: remote);

      expect(result.holds.single.deleted, isTrue);
    });

    test('merging the same payload twice equals merging it once', () {
      final local = _payload(
        holds: [_hold(id: 'a', updatedAt: 1, durationMs: 1000)],
      );
      final remote = _payload(
        holds: [_hold(id: 'a', updatedAt: 3, durationMs: 3000)],
      );

      final once = SyncMergeService.merge(local: local, remote: remote);
      final mergedPayload = _payload(holds: once.holds);
      final twice = SyncMergeService.merge(
        local: mergedPayload,
        remote: remote,
      );

      expect(twice.holds.single.durationMs, 3000);
      expect(twice.counts.holdsUpdated, 0);
      expect(twice.counts.holdsAdded, 0);
    });

    test(
      'the winning hold brings its full tag set, replacing the local one',
      () {
        final local = _payload(
          holds: [
            _hold(id: 'a', updatedAt: 1, tagIds: ['tired']),
          ],
        );
        final remote = _payload(
          holds: [
            _hold(id: 'a', updatedAt: 2, tagIds: ['coldWater', 'anxious']),
          ],
        );

        final result = SyncMergeService.merge(local: local, remote: remote);

        expect(result.holds.single.tagIds, ['coldWater', 'anxious']);
      },
    );

    test('merging into an empty local payload reproduces the remote set', () {
      final local = _payload();
      final remote = _payload(
        holds: [
          _hold(id: 'a', updatedAt: 1),
          _hold(id: 'b', updatedAt: 1),
        ],
        tags: [
          SyncTagRecord(
            id: 't1',
            labelKey: 'tag.tired',
            createdAt: 1,
            updatedAt: 1,
            deleted: false,
          ),
        ],
      );

      final result = SyncMergeService.merge(local: local, remote: remote);

      expect(result.holds, hasLength(2));
      expect(result.tags, hasLength(1));
      expect(result.counts.holdsAdded, 2);
      expect(result.counts.tagsAdded, 1);
    });

    test(
      'tags tiebreak on labelKey (they carry no device_id) and converge',
      () {
        SyncTagRecord tag(
          String id, {
          required int updatedAt,
          required String labelKey,
        }) => SyncTagRecord(
          id: id,
          labelKey: labelKey,
          createdAt: 1,
          updatedAt: updatedAt,
          deleted: false,
        );

        final onA = _payload(
          tags: [tag('shared-id', updatedAt: 9, labelKey: 'custom:from-a')],
        );
        final onB = _payload(
          tags: [tag('shared-id', updatedAt: 9, labelKey: 'custom:from-b')],
        );

        final mergedOnA = SyncMergeService.merge(local: onA, remote: onB);
        final mergedOnB = SyncMergeService.merge(local: onB, remote: onA);

        expect(mergedOnA.tags.single.labelKey, 'custom:from-b');
        expect(mergedOnB.tags.single.labelKey, 'custom:from-b');
      },
    );
  });
}
