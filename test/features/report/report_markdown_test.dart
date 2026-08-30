import 'dart:io';

import 'package:breath_lab/features/report/report_markdown.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseInline', () {
    test('splits bold, italic and code runs', () {
      final runs = parseInline('plain **bold** and *slant* and `code` end');
      expect(runs.map((r) => r.text), [
        'plain ',
        'bold',
        ' and ',
        'slant',
        ' and ',
        'code',
        ' end',
      ]);
      expect(runs[1].bold, isTrue);
      expect(runs[3].italic, isTrue);
      expect(runs[5].code, isTrue);
    });

    test('leaves an unmatched marker as literal text', () {
      final runs = parseInline('a 2*3 = 6 expression');
      expect(runs, hasLength(1));
      expect(runs.single.text, 'a 2*3 = 6 expression');
    });
  });

  group('parseReport', () {
    test('reads headings, paragraphs and both list kinds', () {
      const src = '''
# Title

## Section {#sec}

A paragraph that runs
across two source lines.

- first bullet
- second bullet

1. first step
2. second step
''';
      final blocks = parseReport(src);

      final heading = blocks.whereType<HeadingBlock>().firstWhere(
        (h) => h.level == 2,
      );
      expect(heading.plainText, 'Section');
      expect(heading.anchor, 'sec');

      final paragraph = blocks.whereType<ParagraphBlock>().single;
      expect(
        paragraph.runs.single.text,
        'A paragraph that runs across two source lines.',
      );

      final lists = blocks.whereType<ListBlock>().toList();
      expect(lists, hasLength(2));
      expect(lists[0].ordered, isFalse);
      expect(lists[0].items, hasLength(2));
      expect(lists[1].ordered, isTrue);
      expect(lists[1].items.first.first.text, 'first step');
    });

    test(
      'the bundled report parses with its anchors intact and no raw markers',
      () {
        final src = File(
          'assets/research/breath_holding_research.md',
        ).readAsStringSync();
        final blocks = parseReport(src);

        final anchors = blocks
            .whereType<HeadingBlock>()
            .map((h) => h.anchor)
            .whereType<String>()
            .toSet();
        for (final required in const [
          'mechanisms',
          'capacity',
          'methods',
          'timeline',
          'plan',
          'safety',
          'imst',
          'tables',
        ]) {
          expect(
            anchors,
            contains(required),
            reason: 'missing anchor {#$required}',
          );
        }

        for (final block in blocks.whereType<ParagraphBlock>()) {
          for (final run in block.runs) {
            expect(
              run.text,
              isNot(contains('**')),
              reason: 'unparsed bold marker',
            );
          }
        }
      },
    );
  });
}
