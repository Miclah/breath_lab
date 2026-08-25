import 'package:breath_lab/app.dart';
import 'package:breath_lab/data/repositories/holds_repository.dart';
import 'package:breath_lab/data/repositories/table_sessions_repository.dart';
import 'package:breath_lab/data/repositories/tags_repository.dart';
import 'package:breath_lab/domain/models/hold.dart';
import 'package:breath_lab/domain/models/table_session.dart';
import 'package:breath_lab/features/timer/providers.dart';
import 'package:breath_lab/features/timer/timer_stage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Same reasoning as `progress_screen_test.dart`: the real drift database
/// never resolves under `flutter test`, so the data providers are faked.
List<Override> _fakeDataOverrides() => [
  allHoldsProvider.overrideWith((ref) async => const <Hold>[]),
  allTableSessionsProvider.overrideWith((ref) async => const <TableSession>[]),
  holdTagIdsProvider.overrideWith((ref) async => const <String, Set<String>>{}),
  holdTagCountsProvider.overrideWith((ref) async => const <String, int>{}),
  builtInTagsProvider.overrideWith((ref) async => const []),
];

/// The centre of whatever currently occupies the stage's hero band.
///
/// Deliberately not `find.byType(TimerRing)`: the whole point of the
/// acceptance criterion is that the ring, the prep circle and the result
/// screen's duration number all land on the same spot, and they are three
/// different widgets. The band is the thing that has to hold still.
Offset _heroCentre(WidgetTester tester) {
  final stage = find.byType(TimerStage);
  expect(stage, findsOneWidget);
  final band = find.descendant(
    of: stage,
    matching: find.byWidgetPredicate(
      (w) => w is SizedBox && w.width == double.infinity && w.height != null,
    ),
  );
  // The hero band is the second infinite-width fixed-height box in the
  // stage: the first is the top band.
  return tester.getCenter(band.at(1));
}

Future<ProviderContainer> _pumpTimer(WidgetTester tester, double width) async {
  SharedPreferences.setMockInitialValues({'acknowledged_safety': true});
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final container = ProviderContainer(overrides: _fakeDataOverrides());
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const BreathLabApp(),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

void main() {
  for (final width in [634.0, 1600.0]) {
    testWidgets(
      'the hero centre does not move across idle/prep/hold/done at ${width.toInt()}px',
      (tester) async {
        final container = await _pumpTimer(tester, width);
        final notifier = container.read(timerProvider.notifier);

        final idle = _heroCentre(tester);

        notifier.startPrep(PrepMode.threeSeconds);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        final prep = _heroCentre(tester);

        notifier.beginHold();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        final hold = _heroCentre(tester);

        notifier.stop();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        final done = _heroCentre(tester);

        expect(prep, idle, reason: 'idle -> prep moved the hero');
        expect(hold, idle, reason: 'prep -> hold moved the hero');
        expect(done, idle, reason: 'hold -> result moved the hero');

        notifier.reset();
        await tester.pumpAndSettle();
      },
    );
  }

  testWidgets('emptying the side slot does not move the main column', (
    tester,
  ) async {
    final container = await _pumpTimer(tester, 1600);
    final notifier = container.read(timerProvider.notifier);

    // Idle populates the side panel; holding empties it. Without the
    // reserved slot the main column re-centres and everything in it,
    // including the ring, slides by half the side width plus half the gap.
    final withSide = _heroCentre(tester);

    notifier.startPrep(PrepMode.none);
    notifier.beginHold();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(_heroCentre(tester), withSide);

    notifier.reset();
    await tester.pumpAndSettle();
  });

  group('TimerStage.diameterFor', () {
    test('depends only on the space given, and is capped by the token', () {
      const roomy = BoxConstraints(maxWidth: 600, maxHeight: 900);
      expect(TimerStage.diameterFor(roomy), 280);
    });

    test('shrinks to fit a short window rather than overflowing', () {
      const short = BoxConstraints(maxWidth: 600, maxHeight: 500);
      final d = TimerStage.diameterFor(short);
      expect(d, lessThan(280));
      expect(
        d + TimerStage.leadIn + TimerStage.topBandHeight,
        lessThanOrEqualTo(500 - TimerStage.reservedBelow),
      );
    });

    test('never collapses past the point where the ring stops reading', () {
      const tiny = BoxConstraints(maxWidth: 400, maxHeight: 200);
      expect(TimerStage.diameterFor(tiny), 140);
    });
  });
}
