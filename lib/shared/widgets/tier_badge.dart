import 'package:flutter/material.dart' hide Durations;

import '../../domain/models/evidence_tier.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';

/// The evidence tier of a training mode, shown where the user chooses what to
/// do. An outlined pill — no fill, no shadow — so it states the caveat without
/// competing with the mode it labels.
///
/// [compact] drops the label and shows the letter alone, for rows too tight
/// for the full phrase.
class TierBadge extends StatelessWidget {
  const TierBadge(this.tier, {super.key, this.compact = false});

  final EvidenceTier tier;
  final bool compact;

  Color _color(BreathLabColorScheme c) => switch (tier) {
    EvidenceTier.strong => c.primaryText,
    EvidenceTier.mechanistic => c.textSecondary,
    EvidenceTier.convention => c.textTertiary,
    EvidenceTier.contraindicated => c.dangerText,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final color = _color(c);

    return Semantics(
      label: '${l10n.evidenceTierBadgePrefix}: ${tier.label(l10n)}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm,
          vertical: Spacing.xxs,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Radius.xs),
          border: Border.all(color: color.withValues(alpha: 0.45), width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tier.letter,
              style: BreathLabTypography.micro.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (!compact) ...[
              const SizedBox(width: Spacing.xs),
              Text(
                tier.label(l10n),
                style: BreathLabTypography.micro.copyWith(
                  color: c.textTertiary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
