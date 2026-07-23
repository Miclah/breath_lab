import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/settings_repository.dart';
import '../../domain/services/callout_scheduler.dart';
import '../../l10n/app_localizations_en.dart';
import '../../l10n/app_localizations_sk.dart';
import '../tables/providers.dart' show audioServiceProvider, ttsServiceProvider;
import 'providers.dart';

MilestonePhrases _phrasesFor(String language) {
  if (language == 'sk') {
    final l = AppLocalizationsSk();
    return MilestonePhrases(
      oneMinute: l.ttsMilestoneOneMinute,
      oneThirty: l.ttsMilestoneOneThirty,
      twoMinutes: l.ttsMilestoneTwoMinutes,
      twoThirty: l.ttsMilestoneTwoThirty,
      threeMinutes: l.ttsMilestoneThreeMinutes,
      threeThirty: l.ttsMilestoneThreeThirty,
      fourMinutes: l.ttsMilestoneFourMinutes,
      halfwayToPb: l.ttsHalfwayToPb,
      thirtySecondsToPb: l.ttsThirtySecondsToPb,
      atPb: l.ttsAtPb,
      pastPb: l.ttsPastPb,
    );
  }
  final l = AppLocalizationsEn();
  return MilestonePhrases(
    oneMinute: l.ttsMilestoneOneMinute,
    oneThirty: l.ttsMilestoneOneThirty,
    twoMinutes: l.ttsMilestoneTwoMinutes,
    twoThirty: l.ttsMilestoneTwoThirty,
    threeMinutes: l.ttsMilestoneThreeMinutes,
    threeThirty: l.ttsMilestoneThreeThirty,
    fourMinutes: l.ttsMilestoneFourMinutes,
    halfwayToPb: l.ttsHalfwayToPb,
    thirtySecondsToPb: l.ttsThirtySecondsToPb,
    atPb: l.ttsAtPb,
    pastPb: l.ttsPastPb,
  );
}

/// Invisible widget that speaks TTS time callouts during an active hold,
/// per Settings → Ambient → Spoken callouts. Mount once in the Timer
/// screen's widget tree — renders nothing.
class CalloutListener extends ConsumerStatefulWidget {
  const CalloutListener({super.key});

  @override
  ConsumerState<CalloutListener> createState() => _CalloutListenerState();
}

class _CalloutListenerState extends ConsumerState<CalloutListener> {
  CalloutScheduler? _scheduler;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(timerProvider);

    if (!state.isHolding) {
      _scheduler = null;
      return const SizedBox.shrink();
    }

    final mode = ref.watch(spokenCalloutsModeProvider).valueOrNull;
    final soundEnabled = ref.watch(soundEnabledProvider).valueOrNull ?? true;
    final language = ref.watch(effectiveTtsLanguageProvider).valueOrNull;

    if (mode == null ||
        mode == SpokenCalloutsMode.off ||
        !soundEnabled ||
        language == null) {
      return const SizedBox.shrink();
    }

    _scheduler ??= CalloutScheduler(
      mode: mode,
      pbMs: ref.read(currentMaxMsProvider).valueOrNull,
      phrases: _phrasesFor(language),
      language: language,
    );

    final phrase = _scheduler!.check(state.holdElapsed);
    if (phrase != null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) _speak(phrase);
      });
    }

    return const SizedBox.shrink();
  }

  Future<void> _speak(String phrase) async {
    final audio = ref.read(audioServiceProvider);
    final tts = ref.read(ttsServiceProvider);
    final originalVolume = audio.volume;
    audio.volume = originalVolume * 0.5;
    unawaited(tts.speak(phrase));
    await Future.delayed(const Duration(milliseconds: 500));
    audio.volume = originalVolume;
  }
}
