import 'package:flutter/material.dart' hide Durations;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/hold.dart';
import '../../shared/format_duration.dart';
import '../../shared/widgets/horizontal_scroll_fade.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import 'providers.dart';

/// The holds done today, as a compact row of boxes below the ring.
///
/// PRD §7.1 and Design §`todays-holds` both specify it; neither Phase 1B nor
/// 1D built it, which is half of why the Timer screen reads as unfinished.
/// It is the only place the app answers "what have I already done today"
/// without leaving the screen you train on.
///
/// On a day with nothing logged it renders nothing at all — an empty card
/// with a "no holds yet" line would be a permanent reminder of emptiness on
/// the app's first screen, and the row's whole job is to summarise something
/// that exists.
class TodaysHoldsRow extends ConsumerWidget {
  const TodaysHoldsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holds = ref.watch(todaysHoldsProvider);
    if (holds.isEmpty) return const SizedBox.shrink();

    final c = context.appColors;
    final best = holds.map((h) => h.duration).reduce((a, b) => a > b ? a : b);

    // Marking every hold that ties the best would light up the whole row on
    // a day of consistent holds; the first one to reach it is the one that
    // set it.
    final bestId = holds.firstWhere((h) => h.duration == best).id;

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(Radius.md),
      ),
      padding: const EdgeInsets.all(Spacing.sm),
      child: HorizontalScrollFade(
        width: Spacing.lg,
        color: c.surface,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
          child: Row(
            children: [
              for (final hold in holds)
                Padding(
                  padding: const EdgeInsets.only(right: Spacing.xs),
                  child: _HoldBox(hold: hold, isBest: hold.id == bestId),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HoldBox extends StatelessWidget {
  const _HoldBox({required this.hold, required this.isBest});

  final Hold hold;
  final bool isBest;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: isBest ? c.primary : c.surfaceElevated,
        borderRadius: BorderRadius.circular(Radius.xs),
      ),
      child: Text(
        formatMmSs(hold.duration),
        style: BreathLabTypography.statSm.copyWith(
          color: isBest ? c.textOnPrimary : c.textSecondary,
        ),
      ),
    );
  }
}
