import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';

/// A single metric in [StatCardRow]: label above, value below.
///
/// Deliberately undecorated. Design Revision §2 — "a number with a label is
/// not a card" — and boxing these is what made the Progress screen read as a
/// grid of equal-weight tiles with no subject. The row separates them with
/// hairlines instead.
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
    // No Expanded here either: whether the stat shares a row or stacks in a
    // column is the parent's business, and baking the flex in meant it could
    // only ever be used one way.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
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
