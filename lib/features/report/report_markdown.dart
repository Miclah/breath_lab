/// A deliberately small Markdown model for the bundled research report.
///
/// The report (`assets/research/breath_holding_research.md`) uses only ATX
/// headings, paragraphs, unordered and ordered lists, and the inline runs
/// `**bold**`, `*italic*` and `` `code` ``. There are no tables, images,
/// blockquotes or nested lists, so this parser handles exactly that set and
/// nothing more. A full Markdown package would cost a dependency and a style
/// surface to fight; this is smaller than that fight.
///
/// `*italic*` is parsed but rendered as weight, not slant — the design system
/// bans italics (`BreathLab_Design_revision.md` §6). The model keeps the
/// distinction; the renderer collapses it.
library;

/// An inline run of text with at most one emphasis applied. Runs do not nest —
/// the report never combines `**` and `*` on the same span.
class InlineRun {
  const InlineRun(
    this.text, {
    this.bold = false,
    this.italic = false,
    this.code = false,
  });

  final String text;
  final bool bold;
  final bool italic;
  final bool code;
}

/// A block-level element.
sealed class ReportBlock {
  const ReportBlock();
}

/// An ATX heading. [anchor] is the `{#id}` that was stripped from the end of
/// the heading line, if any; contextual tips resolve to these by name.
class HeadingBlock extends ReportBlock {
  const HeadingBlock({
    required this.level,
    required this.runs,
    required this.plainText,
    this.anchor,
  });

  final int level;
  final List<InlineRun> runs;
  final String plainText;
  final String? anchor;
}

/// A run of body text. Consecutive non-blank lines are joined with a space.
class ParagraphBlock extends ReportBlock {
  const ParagraphBlock(this.runs);
  final List<InlineRun> runs;
}

/// An unordered (`-`) or ordered (`1.`) list. Items are not nested.
class ListBlock extends ReportBlock {
  const ListBlock({required this.ordered, required this.items});
  final bool ordered;
  final List<List<InlineRun>> items;
}

final _headingPattern = RegExp(r'^(#{1,6})\s+(.*)$');
final _anchorPattern = RegExp(r'\s*\{#([A-Za-z0-9][A-Za-z0-9-]*)\}\s*$');
final _bulletPattern = RegExp(r'^[-*]\s+(.*)$');
final _orderedPattern = RegExp(r'^\d+\.\s+(.*)$');

/// Parse the report into a flat list of blocks.
List<ReportBlock> parseReport(String source) {
  final lines = source.replaceAll('\r\n', '\n').split('\n');
  final blocks = <ReportBlock>[];

  var paragraph = <String>[];
  void flushParagraph() {
    if (paragraph.isEmpty) return;
    blocks.add(ParagraphBlock(parseInline(paragraph.join(' '))));
    paragraph = [];
  }

  var listItems = <String>[];
  var listOrdered = false;
  void flushList() {
    if (listItems.isEmpty) return;
    blocks.add(
      ListBlock(
        ordered: listOrdered,
        items: [for (final item in listItems) parseInline(item)],
      ),
    );
    listItems = [];
  }

  for (final raw in lines) {
    final line = raw.trimRight();

    if (line.trim().isEmpty) {
      flushParagraph();
      flushList();
      continue;
    }

    final heading = _headingPattern.firstMatch(line);
    if (heading != null) {
      flushParagraph();
      flushList();
      var text = heading.group(2)!.trim();
      String? anchor;
      final anchorMatch = _anchorPattern.firstMatch(text);
      if (anchorMatch != null) {
        anchor = anchorMatch.group(1);
        text = text.substring(0, anchorMatch.start).trim();
      }
      final runs = parseInline(text);
      blocks.add(
        HeadingBlock(
          level: heading.group(1)!.length,
          runs: runs,
          plainText: runs.map((r) => r.text).join(),
          anchor: anchor,
        ),
      );
      continue;
    }

    final bullet = _bulletPattern.firstMatch(line);
    if (bullet != null) {
      flushParagraph();
      if (listItems.isNotEmpty && listOrdered) flushList();
      listOrdered = false;
      listItems.add(bullet.group(1)!.trim());
      continue;
    }

    final ordered = _orderedPattern.firstMatch(line);
    if (ordered != null) {
      flushParagraph();
      if (listItems.isNotEmpty && !listOrdered) flushList();
      listOrdered = true;
      listItems.add(ordered.group(1)!.trim());
      continue;
    }

    // A continuation line for an open list item.
    if (listItems.isNotEmpty && line.startsWith('  ')) {
      listItems[listItems.length - 1] += ' ${line.trim()}';
      continue;
    }

    flushList();
    paragraph.add(line.trim());
  }

  flushParagraph();
  flushList();
  return blocks;
}

final _tokenPattern = RegExp(r'(\*\*(.+?)\*\*|\*(.+?)\*|`(.+?)`)');

/// Split a single logical line into inline runs. Emphasis does not nest;
/// unmatched markers are left as literal text.
List<InlineRun> parseInline(String text) {
  final runs = <InlineRun>[];
  var index = 0;
  for (final match in _tokenPattern.allMatches(text)) {
    if (match.start > index) {
      runs.add(InlineRun(text.substring(index, match.start)));
    }
    if (match.group(2) != null) {
      runs.add(InlineRun(match.group(2)!, bold: true));
    } else if (match.group(3) != null) {
      runs.add(InlineRun(match.group(3)!, italic: true));
    } else if (match.group(4) != null) {
      runs.add(InlineRun(match.group(4)!, code: true));
    }
    index = match.end;
  }
  if (index < text.length) {
    runs.add(InlineRun(text.substring(index)));
  }
  return runs.isEmpty ? [InlineRun(text)] : runs;
}
