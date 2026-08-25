import 'package:flutter/material.dart' hide Durations;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/settings_repository.dart';
import '../../domain/models/hold.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../progress/providers.dart';
import 'providers.dart';

/// The thin band above the preset chips that PRD §7.1 reserved and nothing
/// ever filled: the current streak on the left, the preset the next hold
/// will actually use on the right.
///
/// The preset half is not decoration. The chips below show which chip is
/// selected, but the selection falls back to the saved default when the
/// user has not touched them this session, and nothing on screen said what
/// that default was — so "Start" could run a two-minute breathing guide
/// with no warning. This states it in words before the button is pressed.
///
/// The streak is here on borrowed time. `RESEARCH_ALIGNMENT.md` §3.1 demotes
/// consecutive-days streaks because they punish the rest day the research
/// prescribes; Phase 3C replaces this half with weekly structure adherence.
class TimerStatusRow extends ConsumerWidget {
  const TimerStatusRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final streak = ref.watch(currentStreakProvider);
    final mode =
        ref.watch(selectedPresetProvider) ??
        ref.watch(defaultPrepModeProvider).valueOrNull ??
        PrepMode.threeSeconds;

    return SizedBox(
      height: 20,
      child: Row(
        children: [
          if (streak > 0)
            _Item(
              icon: Icons.local_fire_department_outlined,
              label: l10n.timerStatusStreak(streak),
              color: c.primaryText,
            ),
          const Spacer(),
          _Item(
            icon: Icons.tune,
            label: _presetLabel(l10n, mode),
            color: c.textTertiary,
          ),
        ],
      ),
    );
  }
}

String _presetLabel(AppLocalizations l10n, PrepMode mode) => switch (mode) {
  PrepMode.none => l10n.presetQuickMax,
  PrepMode.threeSeconds => l10n.presetStandard,
  // `short` has no chip of its own — it is only reachable from Settings —
  // so it borrows the label of the chip nearest it rather than reading as
  // an unnamed fourth mode.
  PrepMode.short || PrepMode.full => l10n.presetFullSession,
};

class _Item extends StatelessWidget {
  const _Item({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: Spacing.xs),
        Text(
          label,
          style: BreathLabTypography.label.copyWith(color: color),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
