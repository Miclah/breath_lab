import 'package:breath_lab/domain/models/hold.dart';
import 'package:breath_lab/domain/models/imst_session.dart';
import 'package:breath_lab/domain/models/table_session.dart';
import 'package:breath_lab/domain/services/adherence_service.dart';
import 'package:flutter_test/flutter_test.dart';

// 2026-07-13 is a Monday.
final _monday = DateTime(2026, 7, 13);
DateTime _day(int offset, [int hour = 9]) =>
    _monday.add(Duration(days: offset)).add(Duration(hours: hour));

Hold _hold(DateTime at, {HoldType type = HoldType.max}) => Hold(
  id: 'h-${at.microsecondsSinceEpoch}-${type.name}',
  createdAt: at,
  updatedAt: at,
  deviceId: 'd',
  duration: const Duration(minutes: 1),
  type: type,
  lungVolume: LungVolume.full,
  isPb: false,
);

TableSession _table(DateTime at) => TableSession(
  id: 't-${at.microsecondsSinceEpoch}',
  createdAt: at,
  updatedAt: at,
  deviceId: 'd',
  type: TableType.co2,
  basedOnMaxMs: 60000,
  roundsTotal: 8,
  roundsCompleted: 8,
  roundDetails: const [],
);

ImstSession _imst(DateTime at) => ImstSession(
  id: 'i-${at.microsecondsSinceEpoch}',
  createdAt: at,
  updatedAt: at,
  deviceId: 'd',
  breaths: 30,
);

void main() {
  group('AdherenceService.forWeek', () {
    test('an empty week scores zero', () {
      final a = AdherenceService.forWeek(
        weekStart: _monday,
        holds: const [],
        tables: const [],
        imst: const [],
      );
      expect(a.score, 0);
      expect(a.percent, 0);
      expect(a.components.every((c) => !c.met), isTrue);
    });

    test('the full target shape scores 100%', () {
      final a = AdherenceService.forWeek(
        weekStart: _monday,
        holds: [
          _hold(_day(0)),
          _hold(_day(3)),
          _hold(_day(6), type: HoldType.rest),
        ],
        tables: [_table(_day(1)), _table(_day(4))],
        imst: [for (var d = 0; d < 5; d++) _imst(_day(d))],
      );
      expect(a.percent, 100);
      expect(a.maxHolds.met, isTrue);
      expect(a.tables.met, isTrue);
      expect(a.imst.met, isTrue);
      expect(a.recovery.met, isTrue);
    });

    test('two max holds on the same day count as one training day', () {
      final a = AdherenceService.forWeek(
        weekStart: _monday,
        holds: [_hold(_day(0, 9)), _hold(_day(0, 18))],
        tables: const [],
        imst: const [],
      );
      expect(a.maxHolds.actual, 1);
      expect(a.maxHolds.met, isFalse);
    });

    test('overshooting a target does not push the score past 100%', () {
      final a = AdherenceService.forWeek(
        weekStart: _monday,
        holds: [for (var d = 0; d < 6; d++) _hold(_day(d))],
        tables: [for (var d = 0; d < 5; d++) _table(_day(d))],
        imst: [for (var d = 0; d < 7; d++) _imst(_day(d))],
        // still no recovery day
      );
      // three of four components maxed, recovery at 0 → 75%
      expect(a.percent, 75);
      expect(a.maxHolds.ratio, 1.0);
      expect(a.tables.ratio, 1.0);
    });

    test('a logged rest day raises adherence rather than breaking it', () {
      final base = AdherenceService.forWeek(
        weekStart: _monday,
        holds: [_hold(_day(0)), _hold(_day(2))],
        tables: const [],
        imst: const [],
      );
      final withRest = AdherenceService.forWeek(
        weekStart: _monday,
        holds: [
          _hold(_day(0)),
          _hold(_day(2)),
          _hold(_day(5), type: HoldType.stretch),
        ],
        tables: const [],
        imst: const [],
      );
      expect(withRest.score, greaterThan(base.score));
    });

    test('sessions outside the week are ignored', () {
      final a = AdherenceService.forWeek(
        weekStart: _monday,
        holds: [_hold(_day(-1)), _hold(_day(7))],
        tables: [_table(_day(9))],
        imst: [_imst(_day(-3))],
      );
      expect(a.score, 0);
    });

    test('weekStartFor returns the Monday of the containing week', () {
      expect(AdherenceService.weekStartFor(DateTime(2026, 7, 16, 23)), _monday);
      expect(AdherenceService.weekStartFor(DateTime(2026, 7, 13)), _monday);
    });
  });
}
