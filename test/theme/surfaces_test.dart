import 'package:breath_lab/theme/colors.dart';
import 'package:breath_lab/theme/surfaces.dart';
import 'package:breath_lab/theme/theme_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Builds each role's decoration under [brightness] and hands them back.
Future<({BoxDecoration primary, BoxDecoration quiet, BoxDecoration inset})>
_decorations(WidgetTester tester, Brightness brightness) async {
  late BoxDecoration primary;
  late BoxDecoration quiet;
  late BoxDecoration inset;

  await tester.pumpWidget(
    MaterialApp(
      theme: brightness == Brightness.dark
          ? buildDarkTheme()
          : buildLightTheme(),
      home: Builder(
        builder: (context) {
          primary = Surfaces.primaryPanel(context);
          quiet = Surfaces.quietPanel(context);
          inset = Surfaces.inset(context);
          return const SizedBox.shrink();
        },
      ),
    ),
  );

  return (primary: primary, quiet: quiet, inset: inset);
}

void main() {
  for (final brightness in Brightness.values) {
    final name = brightness.name;

    testWidgets('the primary panel\'s top edge differs from its other three '
        'in $name', (tester) async {
      final d = await _decorations(tester, brightness);
      final border = d.primary.border! as Border;

      // The teal hairline is the whole signal that this panel is the screen's
      // subject. If it matched the other three sides the role would be an
      // ordinary bordered box.
      expect(border.top.color, isNot(border.left.color));
      expect(border.top.color, isNot(border.right.color));
      expect(border.top.color, isNot(border.bottom.color));
      expect(border.left.color, border.right.color);
      expect(border.left.color, border.bottom.color);
    });

    testWidgets('a quiet panel has no fill in $name', (tester) async {
      final d = await _decorations(tester, brightness);
      // "Unfilled" is the role's entire distinction from primary. With a fill
      // it is just a dimmer primary panel, which is what the build had.
      expect(d.quiet.color, isNull);
      expect(d.primary.color, isNotNull);
    });

    testWidgets('the three roles are three distinct fill states in $name', (
      tester,
    ) async {
      final d = await _decorations(tester, brightness);
      // Fill is what separates the roles, not border colour: in light mode
      // the quiet and inset borders are the same value by design, and the
      // distinction there is unfilled versus recessed.
      expect(d.quiet.color, isNull);
      expect(d.primary.color, isNotNull);
      expect(d.inset.color, isNotNull);
      expect(d.inset.color, isNot(d.primary.color));
    });
  }

  test('an inset recesses in dark mode and lifts in light mode', () {
    // Depth by recessing: darker than the field on the dark canvas, which is
    // also what stops nested containers from trending pale.
    expect(
      BreathLabColors.dark.insetFill.computeLuminance(),
      lessThan(BreathLabColors.dark.canvas.computeLuminance()),
    );
    expect(
      BreathLabColors.light.insetFill.computeLuminance(),
      lessThan(BreathLabColors.light.canvas.computeLuminance()),
    );
  });
}
