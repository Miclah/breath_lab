import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import 'providers.dart';

String _fmtDuration(Duration d) {
  final m = d.inMinutes.toString().padLeft(2, '0');
  final s = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

/// Picture-in-picture content: large mono timer on pure black, per PRD §A3.
/// Uses the dark color scheme regardless of app theme — an OLED-style
/// black background needs consistent contrast, not whatever the current
/// light/dark setting happens to be.
class PipContent extends ConsumerWidget {
  const PipContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final elapsed = ref.watch(timerProvider).holdElapsed;
    final c = BreathLabColors.dark;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _fmtDuration(elapsed),
            style: BreathLabTypography.timerDisplay.copyWith(
              fontSize: 64,
              color: c.primary,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: c.danger,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: Spacing.xs),
              Text(
                AppLocalizations.of(context)!.appTitle,
                style: BreathLabTypography.caption.copyWith(
                  color: c.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
