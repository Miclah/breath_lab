import 'package:flutter/material.dart' hide Durations;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/settings_repository.dart';
import '../../domain/models/hold.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import 'providers.dart';
import 'tag_chip_row.dart';

String _fmt(Duration d) {
  final m = d.inMinutes.toString().padLeft(2, '0');
  final s = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

/// Shown after a hold is stopped. Displays stats, lung volume selector,
/// and Save / Discard buttons. Replaces the timer ring area entirely.
class ResultView extends ConsumerWidget {
  const ResultView({super.key});

  void _resetSessionState(WidgetRef ref) {
    ref.read(selectedLungVolumeProvider.notifier).state = null;
    ref.read(selectedTagIdsProvider.notifier).state = const {};
    ref.read(pendingCustomTagsProvider.notifier).state = const [];
  }

  void _save(WidgetRef ref) {
    // TODO(phase-1b-13): persist hold + tags to DB and check for PB
    _resetSessionState(ref);
    ref.read(timerProvider.notifier).reset();
  }

  void _discard(WidgetRef ref) {
    _resetSessionState(ref);
    ref.read(timerProvider.notifier).reset();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(timerProvider);
    final c = context.appColors;
    final isDesktop = MediaQuery.of(context).size.width >= 600;
    final hPad = isDesktop ? Spacing.xxxl : Spacing.xl;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: Spacing.xxxxl),

          // Hold duration
          Text(
            _fmt(state.holdElapsed),
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: isDesktop ? 64.0 : null,
            ),
          ),

          // Contraction + struggle phase stats
          if (state.contractionTime != null) ...[
            const SizedBox(height: Spacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StatChip(
                  label: l10n.resultContraction,
                  value: _fmt(state.contractionTime!),
                  c: c,
                ),
                if (state.strugglePhase != null) ...[
                  const SizedBox(width: Spacing.xl),
                  _StatChip(
                    label: l10n.resultStruggle,
                    value: _fmt(state.strugglePhase!),
                    c: c,
                  ),
                ],
              ],
            ),
          ],

          const SizedBox(height: Spacing.lg),

          // Tag chips
          const TagChipRow(),

          const Spacer(),

          // Lung volume selector
          const _LungVolumeSelector(),

          const SizedBox(height: Spacing.xxl),

          // Save button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Radius.lg),
                ),
              ),
              onPressed: () => _save(ref),
              child: Text(l10n.resultSaveButton),
            ),
          ),

          // Discard button
          TextButton(
            onPressed: () => _discard(ref),
            child: Text(
              l10n.resultDiscardButton,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: c.textSecondary),
            ),
          ),

          const SizedBox(height: Spacing.xl),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Lung volume selector
// ---------------------------------------------------------------------------

class _LungVolumeSelector extends ConsumerWidget {
  const _LungVolumeSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final isDesktop = MediaQuery.of(context).size.width >= 600;

    final selected =
        ref.watch(selectedLungVolumeProvider) ??
        ref.watch(defaultLungVolumeProvider).valueOrNull ??
        LungVolume.full;

    final segments = [
      (LungVolume.full, l10n.lungVolFull, l10n.lungVolFullHint),
      (LungVolume.frc, l10n.lungVolFrc, l10n.lungVolFrcHint),
      (LungVolume.empty, l10n.lungVolEmpty, l10n.lungVolEmptyHint),
    ];

    final hint = segments.firstWhere((e) => e.$1 == selected).$3;

    Widget selector = Row(
      children: [
        for (final (i, seg) in segments.indexed) ...[
          if (i > 0) Container(width: 0.5, height: 44, color: c.border),
          Expanded(
            child: _LungSegment(volume: seg.$1, label: seg.$2),
          ),
        ],
      ],
    );

    if (isDesktop) {
      selector = Center(child: SizedBox(width: 320, child: selector));
    }

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(Radius.sm),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: c.border, width: 0.5),
              borderRadius: BorderRadius.circular(Radius.sm),
            ),
            height: 44,
            child: selector,
          ),
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          hint,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: c.textTertiary, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _LungSegment extends ConsumerWidget {
  const _LungSegment({required this.volume, required this.label});

  final LungVolume volume;
  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.appColors;
    final selected =
        (ref.watch(selectedLungVolumeProvider) ??
            ref.watch(defaultLungVolumeProvider).valueOrNull ??
            LungVolume.full) ==
        volume;

    return GestureDetector(
      onTap: () => ref.read(selectedLungVolumeProvider.notifier).state = volume,
      child: AnimatedContainer(
        duration: Durations.fast,
        color: selected ? c.primarySurface : Colors.transparent,
        alignment: Alignment.center,
        child: Text(
          label,
          style: BreathLabTypography.button.copyWith(
            color: selected ? c.primaryText : c.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stat chip (label + value pair)
// ---------------------------------------------------------------------------

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value, required this.c});

  final String label;
  final String value;
  final BreathLabColorScheme c;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: c.textTertiary),
        ),
        const SizedBox(height: Spacing.xxs),
        Text(
          value,
          style: BreathLabTypography.statMd.copyWith(color: c.textPrimary),
        ),
      ],
    );
  }
}
