import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';

/// A single metric tile used in [StatCardRow]. Per Design §"Stat Card":
/// label on top in tertiary text, value below in stat-hero mono type.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    // No Expanded here any more: whether the card shares a row or stacks in
    // a column is the parent's business, and baking the flex in meant the
    // card could only ever be used one way.
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(Radius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: BreathLabTypography.label.copyWith(color: c.textTertiary),
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            value,
            style: BreathLabTypography.displayMd.copyWith(
              color: valueColor ?? c.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
