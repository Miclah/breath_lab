import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:breath_lab/shared/widgets/adaptive_page.dart';
import 'package:breath_lab/theme/breakpoints.dart';
import 'package:breath_lab/theme/tokens.dart';

const _contentKey = Key('content');
const _sideKey = Key('side');

/// Lays out an [AdaptivePage] in a box exactly [width] wide, the way the
/// shell hands a screen the space left over beside the navigation rail.
Future<void> _pumpAt(
  WidgetTester tester,
  double width, {
  double maxWidth = ContentWidth.reading,
  bool withSide = true,
}) async {
  // Resize the view rather than wrapping in a SizedBox: a box inside the
  // 800x600 test surface gets clamped to it, which would silently test
  // 800px every time.
  tester.view.physicalSize = Size(width, 600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: AdaptivePage(
        maxWidth: maxWidth,
        side: withSide ? const SizedBox.expand(key: _sideKey) : null,
        child: const SizedBox.expand(key: _contentKey),
      ),
    ),
  );
}

double _widthOf(WidgetTester tester, Key key) =>
    tester.getSize(find.byKey(key)).width;

void main() {
  group('Breakpoint.forWidth', () {
    test('the boundaries are lower-inclusive', () {
      expect(Breakpoint.forWidth(0), Breakpoint.compact);
      expect(Breakpoint.forWidth(599.9), Breakpoint.compact);
      expect(Breakpoint.forWidth(600), Breakpoint.medium);
      expect(Breakpoint.forWidth(1023.9), Breakpoint.medium);
      expect(Breakpoint.forWidth(1024), Breakpoint.expanded);
    });
  });

  group('AdaptivePage', () {
    testWidgets('compact is a single column inset by the page padding', (
      tester,
    ) async {
      await _pumpAt(tester, 400);

      expect(find.byKey(_sideKey), findsNothing);
      // 400 less 20 of padding on each side.
      expect(_widthOf(tester, _contentKey), 360);
    });

    testWidgets('medium is a single column capped at maxWidth', (tester) async {
      await _pumpAt(tester, 800);

      // Room for the side slot's 320 plus the gap, but not the tier for it:
      // one wide window is still one column.
      expect(find.byKey(_sideKey), findsNothing);
      expect(_widthOf(tester, _contentKey), ContentWidth.reading);
    });

    testWidgets('expanded puts the side slot beside the content', (
      tester,
    ) async {
      await _pumpAt(tester, 1400);

      expect(find.byKey(_sideKey), findsOneWidget);
      expect(_widthOf(tester, _contentKey), ContentWidth.reading);
      expect(_widthOf(tester, _sideKey), ContentWidth.side);
      // Side sits to the right of the content, not on top of it.
      expect(
        tester.getTopLeft(find.byKey(_sideKey)).dx,
        greaterThan(tester.getTopRight(find.byKey(_contentKey)).dx),
      );
    });

    testWidgets('a content column too wide to share falls back to one', (
      tester,
    ) async {
      // wide (900) + gap (32) + side (320) needs 1252; 1100 less padding
      // leaves 1036.
      await _pumpAt(tester, 1100, maxWidth: ContentWidth.wide);

      expect(find.byKey(_sideKey), findsNothing);
      expect(_widthOf(tester, _contentKey), ContentWidth.wide);
    });

    testWidgets('no side slot means one column however wide the window is', (
      tester,
    ) async {
      await _pumpAt(tester, 1600, withSide: false);

      expect(_widthOf(tester, _contentKey), ContentWidth.reading);
    });

    testWidgets('the child keeps the full height it would have had', (
      tester,
    ) async {
      await _pumpAt(tester, 400);

      // An Expanded or a ListView inside the child depends on this.
      expect(tester.getSize(find.byKey(_contentKey)).height, 600);
    });
  });
}
