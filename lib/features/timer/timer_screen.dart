import 'package:flutter/material.dart' hide Durations;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/settings_repository.dart';
import '../../domain/models/hold.dart';
import '../../domain/services/timer_service.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import 'preset_chip_row.dart';
import 'prep_phase_widget.dart';
import 'providers.dart';
import 'timer_ring.dart';

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
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      if (!state.isIdle) notifier.reset();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  static String _fmt(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(timerProvider);
    final maxMs = ref.watch(currentMaxMsProvider).valueOrNull;
    final c = context.appColors;
    final isDesktop = MediaQuery.of(context).size.width >= 600;
    final hPad = isDesktop ? Spacing.xxxl : Spacing.xl;

    final ringValue = (maxMs == null || maxMs == 0)
        ? 0.0
        : (state.holdElapsed.inMilliseconds / maxMs).clamp(0.0, 1.5);

    return Scaffold(
      body: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (_, event) => _onKey(event),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad),
            child: Column(
              children: [
                const SizedBox(height: Spacing.lg),
                if (state.isIdle) const PresetChipRow(),
                Expanded(
                  child: state.isPrep
                      ? const PrepPhaseWidget()
                      : _buildRing(
                          context,
                          state,
                          l10n,
                          c,
                          isDesktop,
                          ringValue,
                        ),
                ),
                _buildButton(context, state, l10n, c),
                const SizedBox(height: Spacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRing(
    BuildContext context,
    TimerState state,
    AppLocalizations l10n,
    BreathLabColorScheme c,
    bool isDesktop,
    double ringValue,
  ) {
    final timerStyle = Theme.of(
      context,
    ).textTheme.displayLarge?.copyWith(fontSize: isDesktop ? 64.0 : null);

    final elapsed = state.isIdle ? Duration.zero : state.holdElapsed;

    String? stateLabel;
    if (state.isHolding) stateLabel = l10n.timerStateLabelHold;
    if (state.isDone) stateLabel = l10n.timerStateLabelDone;

    return Center(
      child: TimerRing(
        value: ringValue,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_fmt(elapsed), style: timerStyle),
            if (stateLabel != null) ...[
              const SizedBox(height: Spacing.xs),
              Text(
                stateLabel,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: c.textTertiary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    TimerState state,
    AppLocalizations l10n,
    BreathLabColorScheme c,
  ) {
    if (state.isPrep) return const SizedBox.shrink();

    if (state.isHolding) {
      return SizedBox(
        width: double.infinity,
        height: 48,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: c.danger,
            foregroundColor: c.textOnDanger,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Radius.lg),
            ),
          ),
          onPressed: () => ref.read(timerProvider.notifier).stop(),
          child: Text(l10n.timerStopButton),
        ),
      );
    }

    // idle or done
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radius.lg),
          ),
        ),
        onPressed: state.isDone
            ? () => ref.read(timerProvider.notifier).reset()
            : _startAction,
        child: Text(
          state.isDone ? l10n.timerResetButton : l10n.timerStartButton,
        ),
      ),
    );
  }
}
