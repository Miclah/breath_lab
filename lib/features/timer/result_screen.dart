import 'package:flutter/material.dart' hide Durations;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/device_id_provider.dart';
import '../../data/repositories/holds_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/tags_repository.dart';
import '../../domain/models/hold.dart';
import '../../domain/services/timer_service.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/format_duration.dart';
import '../../shared/global_messenger.dart';
import '../../shared/widgets/adaptive_page.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../tables/providers.dart'
    show audioServiceProvider, hapticsServiceProvider;
import 'providers.dart';
import 'tag_chip_row.dart';
import 'timer_side_panel.dart';
import 'timer_stage.dart';
import 'todays_holds_row.dart';
import '../../theme/surfaces.dart';

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
    ref.read(pendingNoteProvider.notifier).state = '';
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final timerState = ref.read(timerProvider);
      final durationMs = timerState.holdElapsed.inMilliseconds;
      final note = ref.read(pendingNoteProvider).trim();

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
          notes: note.isEmpty ? null : note,
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
    final state = ref.watch(timerProvider);

    // The same stage the timer body uses, so the duration number lands on
    // the pixel the ring's centre was on rather than wherever this screen's
    // own content happened to push it. Design §`hold-result` says the result
    // replaces the ring area; this is what that means geometrically.
    return AdaptivePage(
      maxWidth: ContentWidth.reading,
      reserveSide: true,
      side: const TimerSidePanel(),
      child: TimerStage(
        top: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _PbBadge(),
            SizedBox(height: Spacing.sm),
            _ComparisonLine(),
          ],
        ),
        hero: _ResultHero(
          elapsed: state.holdElapsed,
          pbScale: _pbScale,
          glowController: _glowController,
          glowScale: _glowScale,
          glowOpacity: _glowOpacity,
          showGlow: _showGlow,
        ),
        below: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: Spacing.lg),

              _HoldMetrics(state: state),

              const SizedBox(height: Spacing.lg),

              // What today already looks like, so the number above has
              // something to be read against before it is saved.
              const TodaysHoldsRow(),

              const SizedBox(height: Spacing.lg),

              const TagChipRow(),

              const SizedBox(height: Spacing.lg),

              const _NoteField(),

              const SizedBox(height: Spacing.xxl),

              const _LungVolumeSelector(),

              const SizedBox(height: Spacing.xxl),

              _SaveButton(saving: _saving, onPressed: _save),

              _DiscardButton(saving: _saving, onPressed: _discard),

              const SizedBox(height: Spacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hero
// ---------------------------------------------------------------------------

/// The duration, in the square the ring occupies in every other state.
///
/// The PB glow now fills that square instead of a hard-coded 140 px box —
/// the box existed only to stop the glow appearing from shifting everything
/// below it, and the stage already guarantees that.
class _ResultHero extends StatelessWidget {
  const _ResultHero({
    required this.elapsed,
    required this.pbScale,
    required this.glowController,
    required this.glowScale,
    required this.glowOpacity,
    required this.showGlow,
  });

  final Duration elapsed;
  final Animation<double> pbScale;
  final AnimationController glowController;
  final Animation<double> glowScale;
  final Animation<double> glowOpacity;
  final bool showGlow;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final diameter = constraints.biggest.shortestSide;
        return Stack(
          alignment: Alignment.center,
          children: [
            if (showGlow)
              AnimatedBuilder(
                animation: glowController,
                builder: (_, _) => Opacity(
                  opacity: glowOpacity.value,
                  child: Transform.scale(
                    scale: glowScale.value,
                    child: SizedBox.square(
                      dimension: diameter * 0.5,
                      child: DecoratedBox(
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
              ),
            AnimatedBuilder(
              animation: pbScale,
              builder: (_, child) =>
                  Transform.scale(scale: pbScale.value, child: child),
              child: Text(
                formatMmSs(elapsed),
                // `displayMd`, not the hold screen's `displayLg`: the result
                // is read once, at rest; the hold timer is read at arm's
                // length while trying not to move.
                style: BreathLabTypography.displayMd.copyWith(
                  color: c.textPrimary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Actions
// ---------------------------------------------------------------------------

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.saving, required this.onPressed});

  final bool saving;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(TimerStage.actionBandHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radius.lg),
          ),
        ),
        onPressed: saving ? null : onPressed,
        child: saving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(AppLocalizations.of(context)!.resultSaveButton),
      ),
    );
  }
}

/// Outlined so the only way to throw away a hold doesn't read as bare,
/// borderless text next to a fully filled Save button.
class _DiscardButton extends StatelessWidget {
  const _DiscardButton({required this.saving, required this.onPressed});

  final bool saving;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return OutlinedButton(
      onPressed: saving ? null : onPressed,
      style: OutlinedButton.styleFrom(foregroundColor: c.textSecondary),
      child: Text(AppLocalizations.of(context)!.resultDiscardButton),
    );
  }
}

// ---------------------------------------------------------------------------
// Note field
// ---------------------------------------------------------------------------

/// Writes `Hold.notes`, which until now had a column, a model field and a
/// read-only display in the detail sheet — and no way at all to put
/// anything in it.
///
/// Collapsed by default. The result screen is already the busiest surface
/// in the app and most holds do not want a note; an always-open text box
/// would read as a field waiting to be filled in before Save.
class _NoteField extends ConsumerStatefulWidget {
  const _NoteField();

  @override
  ConsumerState<_NoteField> createState() => _NoteFieldState();
}

class _NoteFieldState extends ConsumerState<_NoteField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _expanded = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _expand() {
    setState(() => _expanded = true);
    // Opening the field and then making the user tap it again is one tap
    // too many for something already behind a disclosure.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  void _collapse() {
    _controller.clear();
    ref.read(pendingNoteProvider.notifier).state = '';
    setState(() => _expanded = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;

    if (!_expanded) {
      return Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: _expand,
          icon: Icon(Icons.add, size: 16, color: c.textSecondary),
          label: Text(
            l10n.resultAddNote,
            style: BreathLabTypography.button.copyWith(color: c.textSecondary),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: (value) =>
                ref.read(pendingNoteProvider.notifier).state = value,
            maxLines: 3,
            minLines: 1,
            style: BreathLabTypography.body.copyWith(color: c.textPrimary),
            decoration: InputDecoration(
              hintText: l10n.resultNoteHint,
              hintStyle: BreathLabTypography.body.copyWith(
                color: c.textTertiary,
              ),
              filled: true,
              fillColor: c.insetFill,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: Spacing.md,
                vertical: Spacing.md,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Radius.sm),
                borderSide: BorderSide(color: c.border, width: 0.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Radius.sm),
                borderSide: BorderSide(color: c.border, width: 0.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Radius.sm),
                borderSide: BorderSide(color: c.primary, width: 0.5),
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: _collapse,
          tooltip: l10n.resultRemoveNote,
          icon: Icon(Icons.close, size: 18, color: c.textTertiary),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// PB badge and comparison line
// ---------------------------------------------------------------------------

/// The `NEW PB` pill from Design §`hold-result`.
///
/// Design assigns it `danger-surface`/`danger-text`; this app already
/// decided otherwise when it introduced [BreathLabColorScheme.recordText] —
/// a record is an achievement, and dressing it in the same red as the
/// safety warnings and the Stop button says the wrong thing about it. The
/// pill follows the token, not the doc.
class _PbBadge extends ConsumerWidget {
  const _PbBadge();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.appColors;
    final elapsed = ref.watch(timerProvider).holdElapsed;
    final currentMaxMs = ref.watch(currentMaxMsProvider).valueOrNull;

    // Same test the save path applies, so the badge cannot promise a record
    // the write then declines to record.
    final isPb = currentMaxMs == null || elapsed.inMilliseconds > currentMaxMs;
    if (!isPb) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: c.primarySurface,
        borderRadius: BorderRadius.circular(Radius.pill),
      ),
      child: Text(
        AppLocalizations.of(context)!.resultNewPbBadge,
        style: BreathLabTypography.micro.copyWith(color: c.recordText),
      ),
    );
  }
}

/// "+00:12 vs last · −00:05 vs PB".
///
/// Both references are shown when both exist, rather than picking one:
/// beating yesterday while sitting short of your best is the ordinary case,
/// and it is two different facts.
///
/// Neither delta is ever red. Design reserves red for events and warnings,
/// and being five seconds off your best on a given day is a normal training
/// session, not either of those.
class _ComparisonLine extends ConsumerWidget {
  const _ComparisonLine();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final elapsed = ref.watch(timerProvider).holdElapsed;
    final currentMaxMs = ref.watch(currentMaxMsProvider).valueOrNull;
    final last = ref.watch(lastMaxHoldProvider);

    final parts = <String>[
      if (last != null)
        l10n.resultVsLast(formatSignedMmSs(elapsed - last.duration)),
      if (currentMaxMs != null && currentMaxMs > 0)
        l10n.resultVsPb(
          formatSignedMmSs(elapsed - Duration(milliseconds: currentMaxMs)),
        ),
    ];

    return Text(
      parts.isEmpty ? l10n.resultFirstHold : parts.join('  ·  '),
      textAlign: TextAlign.center,
      style: BreathLabTypography.micro.copyWith(color: c.textSecondary),
    );
  }
}

// ---------------------------------------------------------------------------
// Hold metrics
// ---------------------------------------------------------------------------

/// Total, time to first contraction, and struggle phase — the three numbers
/// Design §`hold-result` asks for, of which only the first was ever shown.
///
/// Struggle phase carries the accent because it is the metric with the
/// strongest evidence behind it: `RESEARCH_ALIGNMENT.md` §2 records Bourdas
/// & Geladas 2024 placing 59.7 % of measured novice improvement inside it,
/// which is why it is tier A and total time is not. The result screen is
/// the only surface where a user can read it at all.
///
/// Without a marker there is no struggle phase to show, and the row used to
/// vanish entirely — leaving no hint that the app tracks the thing, or that
/// marking it was ever an option. The absence is now the place the feature
/// gets explained.
class _HoldMetrics extends StatelessWidget {
  const _HoldMetrics({required this.state});

  final TimerState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final contraction = state.contractionTime;
    final struggle = state.strugglePhase;

    if (contraction == null || struggle == null) {
      return _NoContractionCard(c: c);
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _StatChip(
              label: l10n.resultTotal,
              value: formatMmSs(state.holdElapsed),
              c: c,
            ),
            const SizedBox(width: Spacing.xl),
            _StatChip(
              label: l10n.resultContraction,
              value: formatMmSs(contraction),
              c: c,
            ),
            const SizedBox(width: Spacing.xl),
            _StatChip(
              label: l10n.resultStruggle,
              value: formatMmSs(struggle),
              c: c,
              valueColor: c.primaryText,
            ),
          ],
        ),
        const SizedBox(height: Spacing.sm),
        Text(
          l10n.resultStruggleNote,
          textAlign: TextAlign.center,
          style: BreathLabTypography.micro.copyWith(color: c.textTertiary),
        ),
      ],
    );
  }
}

class _NoContractionCard extends StatelessWidget {
  const _NoContractionCard({required this.c});

  final BreathLabColorScheme c;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Windows and Android are the only targets, and they do not share an
    // input model — telling a phone user to press C is worse than saying
    // nothing.
    final hint = switch (Theme.of(context).platform) {
      TargetPlatform.android ||
      TargetPlatform.iOS => l10n.resultNoContractionHintTouch,
      _ => l10n.resultNoContractionHintKeyboard,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: Surfaces.quietPanel(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.resultNoContractionTitle,
            style: BreathLabTypography.label.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            '$hint ${l10n.resultNoContractionWhy}',
            style: BreathLabTypography.micro.copyWith(color: c.textTertiary),
          ),
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
          textAlign: TextAlign.center,
          style: BreathLabTypography.micro.copyWith(color: c.textTertiary),
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

    // InkWell rather than GestureDetector: keyboard focus (Tab) skips
    // GestureDetectors entirely, so these segments were unreachable without
    // a mouse.
    return InkWell(
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
  const _StatChip({
    required this.label,
    required this.value,
    required this.c,
    this.valueColor,
  });

  final String label;
  final String value;
  final BreathLabColorScheme c;

  /// Overrides the default `textPrimary`. Used to mark the one figure in a
  /// row that the user should read first.
  final Color? valueColor;

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
          style: BreathLabTypography.numericMd.copyWith(
            color: valueColor ?? c.textPrimary,
          ),
        ),
      ],
    );
  }
}
