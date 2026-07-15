import 'package:flutter_test/flutter_test.dart';
import 'package:breath_lab/domain/models/hold.dart';
import 'package:breath_lab/domain/models/table_session.dart';
import 'package:breath_lab/features/history/history_filters.dart';

Hold _hold({LungVolume lungVolume = LungVolume.full}) {
  return Hold(
    id: 'hold-1',
    createdAt: DateTime(2026, 7, 13),
    updatedAt: DateTime(2026, 7, 13),
    deviceId: 'device',
    duration: const Duration(minutes: 2),
    type: HoldType.max,
    lungVolume: lungVolume,
    isPb: false,
  );
}

TableSession _session(TableType type) {
  return TableSession(
    id: 'session-1',
    createdAt: DateTime(2026, 7, 13),
    updatedAt: DateTime(2026, 7, 13),
    deviceId: 'device',
    type: type,
    basedOnMaxMs: 60000,
    roundsTotal: 7,
    roundsCompleted: 7,
    roundDetails: const [],
  );
}

void main() {
  group('holdMatchesHistoryFilters', () {
    test('matches everything when all filters are empty', () {
      expect(
        holdMatchesHistoryFilters(
          _hold(),
          types: const {},
          lungVolumes: const {},
          tagFilter: const {},
          holdTagIds: const {},
        ),
        isTrue,
      );
    });

    test('excludes holds when Max is not selected', () {
      expect(
        holdMatchesHistoryFilters(
          _hold(),
          types: const {HistoryTypeFilter.co2},
          lungVolumes: const {},
          tagFilter: const {},
          holdTagIds: const {},
        ),
        isFalse,
      );
    });

    test('filters by lung volume', () {
      final hold = _hold(lungVolume: LungVolume.frc);
      expect(
        holdMatchesHistoryFilters(
          hold,
          types: const {},
          lungVolumes: const {LungVolume.full},
          tagFilter: const {},
          holdTagIds: const {},
        ),
        isFalse,
      );
      expect(
        holdMatchesHistoryFilters(
          hold,
          types: const {},
          lungVolumes: const {LungVolume.frc},
          tagFilter: const {},
          holdTagIds: const {},
        ),
        isTrue,
      );
    });

    test('matches if the hold has any of the selected tags', () {
      expect(
        holdMatchesHistoryFilters(
          _hold(),
          types: const {},
          lungVolumes: const {},
          tagFilter: const {'tag-a', 'tag-b'},
          holdTagIds: const {'tag-b'},
        ),
        isTrue,
      );
    });

    test('excludes holds with none of the selected tags', () {
      expect(
        holdMatchesHistoryFilters(
          _hold(),
          types: const {},
          lungVolumes: const {},
          tagFilter: const {'tag-a'},
          holdTagIds: const {'tag-c'},
        ),
        isFalse,
      );
    });

    test('filters combine with AND', () {
      final hold = _hold(lungVolume: LungVolume.full);
      expect(
        holdMatchesHistoryFilters(
          hold,
          types: const {HistoryTypeFilter.max},
          lungVolumes: const {LungVolume.frc},
          tagFilter: const {},
          holdTagIds: const {},
        ),
        isFalse,
      );
    });
  });

  group('tableSessionMatchesHistoryFilters', () {
    test('matches everything when types is empty', () {
      expect(
        tableSessionMatchesHistoryFilters(_session(TableType.co2), const {}),
        isTrue,
      );
    });

    test('matches only its own type when types is set', () {
      expect(
        tableSessionMatchesHistoryFilters(_session(TableType.co2), const {
          HistoryTypeFilter.co2,
        }),
        isTrue,
      );
      expect(
        tableSessionMatchesHistoryFilters(_session(TableType.co2), const {
          HistoryTypeFilter.o2,
        }),
        isFalse,
      );
    });
  });
}
