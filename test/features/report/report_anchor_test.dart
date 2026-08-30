import 'dart:io';

import 'package:breath_lab/features/report/report_anchor.dart';
import 'package:breath_lab/features/report/report_markdown.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every ReportAnchor slug resolves to a heading in the bundled report', () {
    final blocks = parseReport(
      File('assets/research/breath_holding_research.md').readAsStringSync(),
    );
    final anchors = blocks
        .whereType<HeadingBlock>()
        .map((h) => h.anchor)
        .whereType<String>()
        .toSet();

    for (final anchor in ReportAnchor.values) {
      expect(
        anchors,
        contains(anchor.slug),
        reason:
            'ReportAnchor.${anchor.name} points at {#${anchor.slug}}, which is '
            'not a heading in the report — a frozen anchor was renamed or removed.',
      );
    }
  });

  test('slugs are unique', () {
    final slugs = ReportAnchor.values.map((a) => a.slug).toList();
    expect(slugs.toSet(), hasLength(slugs.length));
  });
}
