import 'package:flutter/material.dart' hide Durations;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/device_id_provider.dart';
import '../../data/repositories/holds_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/tags_repository.dart';
import '../../domain/models/hold.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/global_messenger.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../tables/providers.dart'
    show audioServiceProvider, hapticsServiceProvider;
import 'providers.dart';
import 'tag_chip_row.dart';

String _fmt(Duration d) {
  final m = d.inMinutes.toString().padLeft(2, '0');
  final s = (d.inSeconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

/// Shown after a hold is stopped. Displays stats, lung volume selector,
/// and Save / Discard buttons. Replaces the timer ring area entirely.
class ResultView extends ConsumerStatefulWidget {
  const ResultView({super.key});

  @override
  ConsumerState<ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends ConsumerState<ResultView>
    with TickerProviderStateMixin {
  late final AnimationController _pbController;
  late final Animation<double> _pbScale;
  late final AnimationController _glowController;
  late final Animation<double> _glowScale;
  late final Animation<double> _glowOpacity;
  bool _saving = false;
  bool _showGlow = false;

  @override
  void initState() {
    super.initState();
    _pbController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _pbScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.15,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.15,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_pbController);

    // Ring glow: single expansion + fade behind the timer number.
    _glowController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 600),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed && mounted) {
            setState(() => _showGlow = false);
          }
        });
    _glowScale = Tween(
      begin: 0.8,
      end: 1.6,
    ).animate(CurvedAnimation(parent: _glowController, curve: Curves.easeOut));
    _glowOpacity = Tween(
      begin: 0.5,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _glowController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pbController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _resetSessionState() {
    ref.read(selectedLungVolumeProvider.notifier).state = null;
    ref.read(selectedTagIdsProvider.notifier).state = const {};
    ref.read(pendingCustomTagsProvider.notifier).state = const [];
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final timerState = ref.read(timerProvider);
      final durationMs = timerState.holdElapsed.inMilliseconds;

      final LungVolume lungVolume =
          ref.read(selectedLungVolumeProvider) ??
          await ref.read(defaultLungVolumeProvider.future);
      final currentMaxMs = await ref.read(currentMaxMsProvider.future);
      final isPb = currentMaxMs == null || durationMs > currentMaxMs;

      final deviceId = await ref.read(deviceIdProvider.future);
      final holdsRepo = await ref.read(holdsRepositoryProvider.future);
      final tagsRepo = ref.read(tagsRepositoryProvider);

      final holdId = holdsRepo.newId();
      final now = DateTime.now();

      await holdsRepo.save(
        Hold(
          id: holdId,
          createdAt: now,
          updatedAt: now,
          deviceId: deviceId,
          duration: timerState.holdElapsed,
          contractionTime: timerState.contractionTime,
          type: HoldType.max,
          lungVolume: lungVolume,
          prepMode: timerState.prepMode,
          isPb: isPb,
        ),
      );

      final selectedTagIds = ref.read(selectedTagIdsProvider);
      await holdsRepo.saveHoldTags(holdId, selectedTagIds.toList());

      for (final text in ref.read(pendingCustomTagsProvider)) {
        final tag = await tagsRepo.insertCustom(text);
        await holdsRepo.saveHoldTags(holdId, [tag.id]);
      }

      ref.invalidate(allHoldsProvider);
      ref.invalidate(holdTagCountsProvider);

      if (isPb) {
        await ref.read(currentMaxMsProvider.notifier).set(durationMs);
        setState(() => _showGlow = true);
        ref.read(audioServiceProvider).playPbAchieved();
        ref.read(hapticsServiceProvider).pbAchieved();
        await Future.wait([
          _pbController.forward(from: 0),
          _glowController.forward(from: 0),
        ]);
      }
    } catch (error, stackTrace) {
      debugPrint('Failed to save hold: $error\n$stackTrace');
      _reportSaveFailure();
      return;
    } finally {
      if (mounted) setState(() => _saving = false);
    }
    if (!mounted) return;
    _resetSessionState();
    ref.read(timerProvider.notifier).reset();
  }

  void _reportSaveFailure() {
    final messenger = scaffoldMessengerKey.currentState;
    final context = messenger?.context;
    if (messenger == null || context == null) return;
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return;
    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(l10n.resultSaveFailed)));
  }

  void _discard() {
    _resetSessionState();
    ref.read(timerProvider.notifier).reset();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(timerProvider);
    final c = context.appColors;
    final isDesktop = MediaQuery.of(context).size.width >= 600;
    final hPad = isDesktop ? Spacing.xxxl : Spacing.xl;

    // Centered as one cohesive block instead of top-anchored content with a
    // flex Spacer pushing the button group to the physical bottom edge —
    // that left a large empty gap on most screens. SingleChildScrollView
    // guards against overflow on short windows now that nothing here is
    // Expanded/flexible.
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: Spacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Hold duration — pulses on PB, with a glow ring behind it
            Stack(
              alignment: Alignment.center,
              children: [
                if (_showGlow)
                  AnimatedBuilder(
                    animation: _glowController,
                    builder: (_, _) => Opacity(
                      opacity: _glowOpacity.value,
                      child: Transform.scale(
                        scale: _glowScale.value,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                c.recordText.withValues(alpha: 0.5),
                                c.recordText.withValues(alpha: 0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                AnimatedBuilder(
                  animation: _pbScale,
                  builder: (_, child) =>
                      Transform.scale(scale: _pbScale.value, child: child),
                  child: Text(
                    _fmt(state.holdElapsed),
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: isDesktop ? 64.0 : null,
                    ),
                  ),
                ),
              ],
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

            const SizedBox(height: Spacing.xxxl),

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
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.resultSaveButton),
              ),
            ),

            // Discard button
            TextButton(
              onPressed: _saving ? null : _discard,
              child: Text(
                l10n.resultDiscardButton,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: c.textSecondary),
              ),
            ),
          ],
        ),
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

    final selector = Row(
      children: [
        for (final (i, seg) in segments.indexed) ...[
          if (i > 0) Container(width: 0.5, height: 44, color: c.border),
          Expanded(
            child: _LungSegment(volume: seg.$1, label: seg.$2),
          ),
        ],
      ],
    );

    Widget frame = ClipRRect(
      borderRadius: BorderRadius.circular(Radius.sm),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: c.border, width: 0.5),
          borderRadius: BorderRadius.circular(Radius.sm),
        ),
        height: 44,
        child: selector,
      ),
    );

    if (isDesktop) {
      frame = Center(child: SizedBox(width: 320, child: frame));
    }

    return Column(
      children: [
        frame,
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
