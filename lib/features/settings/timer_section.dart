import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/settings_repository.dart';
import '../../domain/models/hold.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/tokens.dart';
import 'section_header.dart';

enum _RatioPreset { fourSix, fourFour, fourEight, custom }

const _ratioPresetValues = {
  _RatioPreset.fourSix: (4, 6),
  _RatioPreset.fourFour: (4, 4),
  _RatioPreset.fourEight: (4, 8),
};

/// Settings → Timer section: prep breathing duration and ratio. Renders
/// nothing (including its own header) unless the default prep mode is
/// Short or Full — the breathing guide is otherwise unused.
class TimerSection extends ConsumerWidget {
  const TimerSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final mode = ref.watch(defaultPrepModeProvider).valueOrNull;
    if (mode != PrepMode.short && mode != PrepMode.full) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: l10n.settingsTimerSection),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.lg,
            vertical: Spacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.settingsPrepDurationLabel,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: Spacing.sm),
              const _PrepDurationStepper(),
              const SizedBox(height: Spacing.xl),
              Text(
                l10n.settingsBreathingRatioLabel,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: Spacing.sm),
              const _BreathingRatioSelector(),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Prep breathing duration stepper
// ---------------------------------------------------------------------------

class _PrepDurationStepper extends ConsumerWidget {
  const _PrepDurationStepper();

  static const _minSeconds = 15;
  static const _maxSeconds = 600;
  static const _stepSeconds = 15;

  static String _format(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _update(WidgetRef ref, int seconds) =>
      ref.read(prepBreathingDurationSecondsProvider.notifier).set(seconds);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seconds =
        ref.watch(prepBreathingDurationSecondsProvider).valueOrNull ?? 120;

    return Row(
      children: [
        IconButton.filledTonal(
          onPressed: seconds > _minSeconds
              ? () => _update(ref, seconds - _stepSeconds)
              : null,
          icon: const Icon(Icons.remove),
        ),
        Expanded(
          child: Text(
            _format(seconds),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        IconButton.filledTonal(
          onPressed: seconds < _maxSeconds
              ? () => _update(ref, seconds + _stepSeconds)
              : null,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Breathing ratio — presets + custom
// ---------------------------------------------------------------------------

class _BreathingRatioSelector extends ConsumerWidget {
  const _BreathingRatioSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final ratio = ref.watch(breathingRatioProvider).valueOrNull ?? (4, 6);
    final preset = _ratioPresetValues.entries
        .firstWhere(
          (e) => e.value == ratio,
          orElse: () => const MapEntry(_RatioPreset.custom, (0, 0)),
        )
        .key;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<_RatioPreset>(
          segments: [
            const ButtonSegment(
              value: _RatioPreset.fourSix,
              label: Text('4:6'),
            ),
            const ButtonSegment(
              value: _RatioPreset.fourFour,
              label: Text('4:4'),
            ),
            const ButtonSegment(
              value: _RatioPreset.fourEight,
              label: Text('4:8'),
            ),
            ButtonSegment(
              value: _RatioPreset.custom,
              label: Text(l10n.settingsBreathingRatioCustom),
            ),
          ],
          selected: {preset},
          showSelectedIcon: false,
          onSelectionChanged: (value) {
            final presetValue = _ratioPresetValues[value.first];
            if (presetValue == null) return;
            ref.read(breathingRatioProvider.notifier).set(presetValue);
          },
        ),
        if (preset == _RatioPreset.custom) ...[
          const SizedBox(height: Spacing.md),
          _CustomRatioInputs(inhaleSeconds: ratio.$1, exhaleSeconds: ratio.$2),
        ],
      ],
    );
  }
}

class _CustomRatioInputs extends ConsumerWidget {
  const _CustomRatioInputs({
    required this.inhaleSeconds,
    required this.exhaleSeconds,
  });

  final int inhaleSeconds;
  final int exhaleSeconds;

  static const _minSeconds = 2;
  static const _maxSeconds = 15;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    Future<void> update(int inhale, int exhale) =>
        ref.read(breathingRatioProvider.notifier).set((inhale, exhale));

    return Row(
      children: [
        Expanded(
          child: _RatioValueStepper(
            label: l10n.settingsBreathingRatioInhaleLabel,
            seconds: inhaleSeconds,
            onChanged: (v) => update(v, exhaleSeconds),
          ),
        ),
        const SizedBox(width: Spacing.lg),
        Expanded(
          child: _RatioValueStepper(
            label: l10n.settingsBreathingRatioExhaleLabel,
            seconds: exhaleSeconds,
            onChanged: (v) => update(inhaleSeconds, v),
          ),
        ),
      ],
    );
  }
}

class _RatioValueStepper extends StatelessWidget {
  const _RatioValueStepper({
    required this.label,
    required this.seconds,
    required this.onChanged,
  });

  final String label;
  final int seconds;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: Spacing.xxs),
        Row(
          children: [
            IconButton.filledTonal(
              onPressed: seconds > _CustomRatioInputs._minSeconds
                  ? () => onChanged(seconds - 1)
                  : null,
              icon: const Icon(Icons.remove),
            ),
            Expanded(
              child: Text(
                '${seconds}s',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton.filledTonal(
              onPressed: seconds < _CustomRatioInputs._maxSeconds
                  ? () => onChanged(seconds + 1)
                  : null,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ],
    );
  }
}
