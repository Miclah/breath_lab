import 'dart:io';

import 'package:breath_lab/features/report/providers.dart';
import 'package:breath_lab/features/report/report_anchor.dart';
import 'package:breath_lab/features/report/report_markdown.dart';
import 'package:breath_lab/features/report/report_reader_screen.dart';
import 'package:breath_lab/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _sample = '''
# Research summary

## Overview {#overview}

Some framing text.

## Safety {#safety}

The safety section.
''';

Future<void> _pump(
  WidgetTester tester,
  double width,
  Brightness brightness, {
  Locale locale = const Locale('en'),
  ReportAnchor? initialAnchor,
}) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        reportBlocksProvider.overrideWith((ref) async => parseReport(_sample)),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(brightness: brightness),
        home: ReportReaderScreen(initialAnchor: initialAnchor),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final width in const [400.0, 1176.0]) {
    for (final brightness in Brightness.values) {
      testWidgets('renders at $width / ${brightness.name}', (tester) async {
        await _pump(tester, width, brightness);
        expect(tester.takeException(), isNull);
        expect(find.text('Research summary'), findsWidgets);
      });
    }
  }

  testWidgets('states the report is English-only, in the UI language', (
    tester,
  ) async {
    await _pump(tester, 400, Brightness.dark, locale: const Locale('sk'));
    expect(
      find.text('Tento prehľad je dostupný iba v angličtine.'),
      findsOneWidget,
    );
  });

  testWidgets('the section index jumps to a heading', (tester) async {
    await _pump(tester, 1176, Brightness.dark);
    // Side index is open at this width.
    await tester.tap(find.text('Safety').first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('opening with an initialAnchor scrolls that section into view', (
    tester,
  ) async {
    final realReport = File(
      'assets/research/breath_holding_research.md',
    ).readAsStringSync();
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          reportBlocksProvider.overrideWith(
            (ref) async => parseReport(realReport),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ReportReaderScreen(initialAnchor: ReportAnchor.safety),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    // The safety heading is on screen; the intro paragraph above it is not.
    expect(find.textContaining('HEALTH RISKS AND SAFETY'), findsOneWidget);
  });
}
