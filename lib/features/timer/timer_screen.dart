import 'package:flutter/material.dart' hide Durations;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/settings_repository.dart';
import '../../domain/models/hold.dart';
import '../../domain/services/timer_service.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/format_duration.dart';
import '../../shared/widgets/adaptive_page.dart';
import '../imst/imst_log_screen.dart';
import 'log_session_sheet.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import 'preset_chip_row.dart';
import 'prep_phase_widget.dart';
import 'providers.dart';
import 'result_screen.dart';
import 'timer_ring.dart';
import 'timer_side_panel.dart';
import 'timer_stage.dart';
import 'timer_status_row.dart';
import 'todays_holds_row.dart';
import '../../shared/widgets/primary_action.dart';

class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({super.key});

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _startAction() {
    final mode =
        ref.read(selectedPresetProvider) ??
        ref.read(defaultPrepModeProvider).valueOrNull ??
        PrepMode.threeSeconds;
    final notifier = ref.read(timerProvider.notifier);
    notifier.startPrep(mode);
    if (mode == PrepMode.none) notifier.beginHold();
  }

  KeyEventResult _onKey(KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final state = ref.read(timerProvider);
    final notifier = ref.read(timerProvider.notifier);
    if (event.logicalKey == LogicalKeyboardKey.space) {
      if (state.isIdle) {
        _startAction();
      } else if (state.isPrep) {
        notifier.beginHold();
      } else if (state.isHolding) {
        notifier.stop();
      } else if (state.isDone) {
        notifier.reset();
      }
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.keyC) {
      ref.read(timerProvider.notifier).markContraction();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      if (!state.isIdle) notifier.reset();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(timerProvider);
    final maxMs = ref.watch(currentMaxMsProvider).valueOrNull;
    final c = context.appColors;

    final ringValue = (maxMs == null || maxMs == 0)
        ? 0.0
        // Capped at 2.0 rather than 1.5: the ring's overflow arc closes at
        // double the PB, and clamping below that hid its top half.
        : (state.holdElapsed.inMilliseconds / maxMs).clamp(0.0, 2.0);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navTimer),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.add),
            tooltip: l10n.logMenuTooltip,
            onSelected: (value) {
              switch (value) {
                case 'imst':
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ImstLogScreen(),
                    ),
                  );
                case 'rest':
                  showLogSessionSheet(context, LoggableSession.rest);
                case 'stretch':
                  showLogSessionSheet(context, LoggableSession.stretch);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'imst', child: Text(l10n.imstLogOpen)),
              PopupMenuItem(value: 'rest', child: Text(l10n.logRestMenuItem)),
              PopupMenuItem(
                value: 'stretch',
                child: Text(l10n.logStretchMenuItem),
              ),
            ],
          ),
        ],
      ),
      body: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (_, event) => _onKey(event),
        child: SafeArea(
          child: state.isDone
              ? const ResultView()
              : AdaptivePage(
                  maxWidth: ContentWidth.wide,
                  // Held open in every state. During PREP and HOLD the slot
                  // is deliberately empty — Design's "don't crowd the timer
                  // screen" — but its width stays reserved so the main
                  // column, and with it the ring, does not slide sideways
                  // when it empties.
                  reserveSide: true,
                  centerVertically: true,
                  side: state.isIdle ? const TimerSidePanel() : null,
                  child: TimerStage(
                    // Every band carries something in every state, or
                    // carries nothing and keeps its height. What changes is
                    // the contents, and those crossfade.
                    top: switch (state.phase) {
                      TimerPhase.idle => const Column(
                        children: [
                          TimerStatusRow(),
                          SizedBox(height: Spacing.md),
                          PresetChipRow(),
                        ],
                      ),
                      TimerPhase.prep => const PrepTopLabel(),
                      _ => null,
                    },
                    hero: AnimatedSwitcher(
                      duration: Durations.normal,
                      child: state.isPrep
                          ? const PrepPhaseWidget(key: ValueKey('prep'))
                          : KeyedSubtree(
                              key: const ValueKey('ring'),
                              child: _buildRing(
                                context,
                                state,
                                l10n,
                                c,
                                ringValue,
                              ),
                            ),
                    ),
                    below: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: Spacing.md),
                        StageBand(
                          height: TimerStage.contractionBandHeight,
                          child: state.isPrep
                              ? const PrepCountdown()
                              : state.contractionTime == null
                              ? null
                              : _ContractionBadge(time: state.contractionTime!),
                        ),
                        const SizedBox(height: Spacing.sm),
                        StageBand(
                          height: TimerStage.holdsBandHeight,
                          child: state.isIdle ? const TodaysHoldsRow() : null,
                        ),
                        const SizedBox(height: Spacing.md),
                        StageBand(
                          height: TimerStage.actionBandHeight,
                          child: state.isPrep
                              ? const PrepActionButton()
                              : _buildButton(context, state, l10n, c),
                        ),
                        const SizedBox(height: Spacing.xl),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  /// The ring, sized and positioned by [TimerStage] rather than by whatever
  /// height the surrounding rows happened to leave it.
  Widget _buildRing(
    BuildContext context,
    TimerState state,
    AppLocalizations l10n,
    BreathLabColorScheme c,
    double ringValue,
  ) {
    final elapsed = state.isIdle ? Duration.zero : state.holdElapsed;

    return LayoutBuilder(
      builder: (context, constraints) {
        final diameter = constraints.biggest.shortestSide;
        // `displayLg` is 72, sized for the 280 ring. Five monospace glyphs at
        // 72 are wider than a 220 ring, so below the expanded diameter the
        // figure scales to the circle it has to sit inside — the ring can be
        // any size between the two tokens, not just one of them.
        final timerStyle = BreathLabTypography.displayLg.copyWith(
          color: c.textPrimary,
          fontSize: diameter >= TimerRing.expandedDiameter
              ? null
              : BreathLabTypography.displayLg.fontSize! *
                    (diameter / TimerRing.expandedDiameter),
        );

        return GestureDetector(
          onDoubleTap: () => ref.read(timerProvider.notifier).markContraction(),
          child: TimerRing(
            value: ringValue,
            elapsed: elapsed,
            size: diameter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(formatMmSs(elapsed), style: timerStyle),
                // Reserved, not conditional: a label that appears only while
                // holding would shift the number inside a ring whose own
                // centre is fixed.
                SizedBox(
                  height: 16,
                  child: AnimatedSwitcher(
                    duration: Durations.normal,
                    child: !state.isHolding
                        ? const SizedBox.shrink()
                        : Text(
                            l10n.timerStateLabelHold,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: c.textTertiary),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildButton(
    BuildContext context,
    TimerState state,
    AppLocalizations l10n,
    BreathLabColorScheme c,
  ) {
    if (state.isHolding) {
      // Outline, not a red slab. Design gives red to events — "when it
      // appears, it means something happened" — and a fill that sits there
      // for three minutes is the opposite of an event. It was also the
      // loudest thing on the screen for the whole hold, which the timer
      // number is supposed to be. The colour stays; only the fill goes.
      return PrimaryAction(
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: c.dangerText,
            side: BorderSide(color: c.danger, width: 0.5),
          ),
          onPressed: () => ref.read(timerProvider.notifier).stop(),
          child: Text(l10n.timerStopButton),
        ),
      );
    }

    // idle — Start button
    return PrimaryAction(
      child: FilledButton(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(TimerStage.actionBandHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radius.lg),
          ),
        ),
        onPressed: _startAction,
        child: Text(l10n.timerStartButton),
      ),
    );
  }
}

/// Small indicator shown below the ring when the first contraction is marked.
class _ContractionBadge extends StatelessWidget {
  const _ContractionBadge({required this.time});

  final Duration time;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: c.primary, shape: BoxShape.circle),
        ),
        const SizedBox(width: Spacing.xs),
        Text(
          formatMmSs(time),
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: c.textSecondary),
        ),
      ],
    );
  }
}
