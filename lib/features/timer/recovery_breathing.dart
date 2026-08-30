import 'dart:async';

import 'package:flutter/material.dart' hide Durations;

import '../../domain/models/evidence_tier.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/tier_badge.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';

/// The three phases of one hook breath, and how long to hold each cue.
enum _HookPhase { inhale, hook, exhale }

const _phaseSeconds = {
  _HookPhase.inhale: 2,
  _HookPhase.hook: 2,
  _HookPhase.exhale: 1,
};
const _breathCount = 3;

/// A guided three-hook-breath recovery sequence for after a max hold.
///
/// Framed as diving-medicine practice — tier C, `RESEARCH_ALIGNMENT.md` §2 —
/// never as evidence: there is no controlled data that it improves anything,
/// only a long convention that it steadies the first half-minute after a
/// hold. Collapsed until the user starts it, so it never nags.
class RecoveryBreathingPrompt extends StatefulWidget {
  const RecoveryBreathingPrompt({super.key});

  @override
  State<RecoveryBreathingPrompt> createState() =>
      _RecoveryBreathingPromptState();
}

class _RecoveryBreathingPromptState extends State<RecoveryBreathingPrompt> {
  Timer? _timer;
  int _breath = 0; // 1..3 while running, 0 idle
  _HookPhase _phase = _HookPhase.inhale;
  bool _done = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    setState(() {
      _breath = 1;
      _phase = _HookPhase.inhale;
      _done = false;
    });
    _scheduleNext();
  }

  void _scheduleNext() {
    _timer?.cancel();
    _timer = Timer(Duration(seconds: _phaseSeconds[_phase]!), () {
      if (!mounted) return;
      setState(() {
        switch (_phase) {
          case _HookPhase.inhale:
            _phase = _HookPhase.hook;
          case _HookPhase.hook:
            _phase = _HookPhase.exhale;
          case _HookPhase.exhale:
            if (_breath >= _breathCount) {
              _breath = 0;
              _done = true;
              return;
            }
            _breath++;
            _phase = _HookPhase.inhale;
        }
      });
      if (_breath != 0) _scheduleNext();
    });
  }

  String _cue(AppLocalizations l10n) => switch (_phase) {
    _HookPhase.inhale => l10n.recoveryCueInhale,
    _HookPhase.hook => l10n.recoveryCueHook,
    _HookPhase.exhale => l10n.recoveryCueExhale,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final running = _breath != 0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.recoveryTitle.toUpperCase(),
              style: BreathLabTypography.section.copyWith(
                color: c.textTertiary,
              ),
            ),
            const SizedBox(width: Spacing.sm),
            const TierBadge(EvidenceTier.convention, compact: true),
          ],
        ),
        const SizedBox(height: Spacing.sm),
        if (running)
          Text(
            l10n.recoveryProgress(_cue(l10n), _breath, _breathCount),
            style: BreathLabTypography.numericMd.copyWith(color: c.primaryText),
          )
        else
          Text(
            _done ? l10n.recoveryDone : l10n.recoveryBlurb,
            textAlign: TextAlign.center,
            style: BreathLabTypography.micro.copyWith(color: c.textTertiary),
          ),
        if (!running && !_done) ...[
          const SizedBox(height: Spacing.sm),
          OutlinedButton(onPressed: _start, child: Text(l10n.recoveryStart)),
        ],
      ],
    );
  }
}
