import 'package:flutter/material.dart';

import '../../features/report/report_anchor.dart';
import '../../features/report/report_reader_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/surfaces.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';

/// An authored excerpt from the research, placed where the decision it bears
/// on is made (`RESEARCH_ALIGNMENT.md` §5).
///
/// A quiet panel — no fill, no icon, no accent except the one "read more"
/// link — so it recedes until the user wants it. The excerpt is an ARB string
/// and is fully localised; the report it links into is English-only.
class ContextualTip extends StatelessWidget {
  const ContextualTip({super.key, required this.text, required this.anchor});

  /// The authored, localised excerpt. Must not overstate the evidence — a
  /// tier-B or tier-C mode is never described as equivalent to a tier-A one.
  final String text;

  /// Where "read more" lands in the reader.
  final ReportAnchor anchor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: Surfaces.quietPanel(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: BreathLabTypography.body.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: Spacing.sm),
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
      ),
    );
  }
}
