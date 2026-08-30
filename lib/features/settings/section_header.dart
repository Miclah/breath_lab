import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';

/// Section header at the top of each Settings group.
///
/// Not teal. Design allows "one teal element per visual group maximum", and
/// every header being the accent colour meant the accent marked nothing —
/// on a screen where teal already means "this control is on", nine teal
/// headings compete with the only teal that carries information.
///
/// The uppercase muted label is the treatment the rest of the app already
/// uses for a group heading: the heatmap's title, the timer side panel's
/// cards, the tables summary.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.lg,
        Spacing.xxl,
        Spacing.lg,
        Spacing.sm,
      ),
      child: Text(
        title.toUpperCase(),
        style: BreathLabTypography.section.copyWith(color: c.textTertiary),
      ),
    );
  }
}
