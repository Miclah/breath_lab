import 'dart:io';

import 'package:breath_lab/features/report/report_block_view.dart';
import 'package:breath_lab/features/report/report_markdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(
  WidgetTester tester,
  double width,
  Brightness brightness,
  List<ReportBlock> blocks,
) async {
  tester.view.physicalSize = Size(width, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(brightness: brightness),
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [for (final b in blocks) ReportBlockView(b)],
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  final blocks = parseReport(
    File('assets/research/breath_holding_research.md').readAsStringSync(),
  );

  for (final width in const [360.0, 634.0, 1176.0]) {
    for (final brightness in Brightness.values) {
      testWidgets('renders the full report at $width / ${brightness.name}', (
        tester,
      ) async {
        await _pump(tester, width, brightness, blocks);
        expect(tester.takeException(), isNull);
        expect(find.byType(ReportBlockView), findsWidgets);
      });
    }
  }

  testWidgets('bold and code runs render without leaking their markers', (
    tester,
  ) async {
    final sample = parseReport('A **bold** word and `code` here.');
    await _pump(tester, 360, Brightness.dark, sample);
    expect(find.textContaining('**'), findsNothing);
    expect(find.textContaining('`'), findsNothing);
  });
}
