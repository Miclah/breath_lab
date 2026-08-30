import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import 'report_markdown.dart';

/// Renders one [ReportBlock] through the app's own type tokens, so the
/// research reader looks like BreathLab rather than like a document viewer.
///
/// The design system bans italics (`BreathLab_Design_revision.md` §6), so a
/// `*slant*` run in the source comes out as weight 500 — the same as `**bold**`.
/// The distinction is kept in the model and dropped here on purpose.
class ReportBlockView extends StatelessWidget {
  const ReportBlockView(this.block, {super.key});

  final ReportBlock block;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;

    return switch (block) {
      HeadingBlock(:final level, :final plainText) => Padding(
        padding: EdgeInsets.only(top: _headingGap(level), bottom: Spacing.xs),
        child: level <= 1
            ? Text(
                plainText,
                style: BreathLabTypography.title.copyWith(color: c.textPrimary),
              )
            : Text(
                // `section` is letterspaced small caps everywhere in the app;
                // the style cannot uppercase itself. Level shows only in the
                // gap above — the section index carries the hierarchy.
                plainText.toUpperCase(),
                style: BreathLabTypography.section.copyWith(
                  color: c.textTertiary,
                ),
              ),
      ),
      ParagraphBlock(:final runs) => Padding(
        padding: const EdgeInsets.only(top: Spacing.md),
        child: Text.rich(
          _spans(
            runs,
            BreathLabTypography.body.copyWith(color: c.textSecondary),
          ),
        ),
      ),
      ListBlock(:final ordered, :final items) => Padding(
        padding: const EdgeInsets.only(top: Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (i, item) in items.indexed)
              Padding(
                padding: EdgeInsets.only(top: i == 0 ? 0 : Spacing.xs),
                child: _ListItem(
                  marker: ordered ? '${i + 1}.' : '·',
                  runs: item,
                ),
              ),
          ],
        ),
      ),
    };
  }

  static double _headingGap(int level) => switch (level) {
    <= 1 => 0,
    2 => Spacing.xxl,
    3 => Spacing.xl,
    _ => Spacing.lg,
  };
}

class _ListItem extends StatelessWidget {
  const _ListItem({required this.marker, required this.runs});

  final String marker;
  final List<InlineRun> runs;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final base = BreathLabTypography.body.copyWith(color: c.textSecondary);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: Spacing.xl,
          child: Text(
            marker,
            style: base.copyWith(color: c.textTertiary),
            textAlign: TextAlign.left,
          ),
        ),
        Expanded(child: Text.rich(_spans(runs, base))),
      ],
    );
  }
}

/// Build the [TextSpan] tree for a run of inline text. Emphasis — bold or the
/// collapsed italic — becomes weight 500; `code` becomes the mono face.
TextSpan _spans(List<InlineRun> runs, TextStyle base) {
  final mono = base.copyWith(
    fontFamily: BreathLabTypography.numericSm.fontFamily,
    fontFamilyFallback: const [],
  );
  return TextSpan(
    children: [
      for (final run in runs)
        TextSpan(
          text: run.text,
          style: run.code
              ? mono
              : (run.bold || run.italic
                    ? base.copyWith(fontWeight: FontWeight.w500)
                    : base),
        ),
    ],
  );
}
