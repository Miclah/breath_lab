import 'package:breath_lab/features/report/providers.dart';
import 'package:breath_lab/features/report/report_anchor.dart';
import 'package:breath_lab/features/report/report_markdown.dart';
import 'package:breath_lab/features/report/report_reader_screen.dart';
import 'package:breath_lab/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// End to end: the bundled asset, through the parser, into the reader.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<ReportBlock> blocks;

  setUpAll(() async {
    final source = await rootBundle.loadString(reportAssetPath);
    expect(source, isNotEmpty);
    blocks = parseReport(source);
  });

  Widget app({ReportAnchor? anchor}) => ProviderScope(
    overrides: [reportBlocksProvider.overrideWith((ref) async => blocks)],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: ReportReaderScreen(initialAnchor: anchor),
    ),
  );

  test('every ReportAnchor slug is a heading in the bundled report', () {
    final anchors = blocks
        .whereType<HeadingBlock>()
        .map((h) => h.anchor)
        .whereType<String>()
        .toSet();
    for (final anchor in ReportAnchor.values) {
      expect(anchors, contains(anchor.slug));
    }
  });

  for (final width in const [360.0, 634.0, 1176.0]) {
    testWidgets('reader renders the whole report at $width without overflow', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      // SingleChildScrollView lays out all children eagerly, so any overflow
      // has already been caught on pump.
      expect(tester.takeException(), isNull);
      expect(find.textContaining('HEALTH RISKS AND SAFETY'), findsOneWidget);
    });
  }

  testWidgets('opening at each anchor lands without an assert', (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    for (final anchor in ReportAnchor.values) {
      await tester.pumpWidget(app(anchor: anchor));
      await tester.pumpAndSettle();
      expect(
        tester.takeException(),
        isNull,
        reason: 'deep link to ${anchor.name} threw',
      );
    }
  });
}
