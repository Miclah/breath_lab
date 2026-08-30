import 'package:flutter/material.dart';

import '../../features/report/report_anchor.dart';
import '../../features/report/report_reader_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';

/// An authored excerpt from the research, placed where the decision it bears
/// on is made (`RESEARCH_ALIGNMENT.md` §5).
///
/// No chrome of its own — no border, no fill, no icon, and the "read more"
/// link the only accent. It is supporting text that composes into whatever
/// panel already holds the mode it explains, so it does not add a second
/// surface role where a screen already has its one primary panel. The excerpt
/// is an ARB string and is fully localised; the report it links into is
/// English-only.
class ContextualTip extends StatelessWidget {
  const ContextualTip({
    super.key,
    required this.text,
    required this.anchor,
    this.style,
    this.center = false,
  });

  /// The authored, localised excerpt. Must not overstate the evidence — a
  /// tier-B or tier-C mode is never described as equivalent to a tier-A one.
  final String text;

  /// Where "read more" lands in the reader.
  final ReportAnchor anchor;

  /// Overrides the excerpt text style, so a tip placed among `micro` helper
  /// lines matches them rather than standing above them.
  final TextStyle? style;

  /// Centre the excerpt and the link, for a block that is itself centred
  /// (the result screen's struggle-phase metric).
  final bool center;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;

    return Column(
      crossAxisAlignment: center
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          text,
          textAlign: center ? TextAlign.center : TextAlign.start,
          style:
              style ??
              BreathLabTypography.body.copyWith(color: c.textSecondary),
        ),
        const SizedBox(height: Spacing.xs),
        TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            foregroundColor: c.primary,
          ),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ReportReaderScreen(initialAnchor: anchor),
            ),
          ),
          child: Text(
            l10n.contextualTipReadMore,
            style: BreathLabTypography.label.copyWith(color: c.primary),
          ),
        ),
      ],
    );
  }
}
