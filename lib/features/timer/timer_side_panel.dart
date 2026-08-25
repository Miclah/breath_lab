import 'package:flutter/material.dart' hide Durations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../data/repositories/holds_repository.dart';
import '../../domain/models/hold.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/format_duration.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import '../../theme/surfaces.dart';

/// What goes beside the ring at [Breakpoint.expanded], and only there.
///
/// It exists on IDLE alone. During PREP and HOLD the slot is empty by
/// design — Design's "don't animate during an active hold" and "don't crowd
/// the timer screen" both point the same way, and a panel of statistics
/// beside someone trying to lie still contradicts them. The width stays
/// reserved regardless, so emptying it does not move anything.
///
/// Nothing here is reachable only from here. On a phone the slot does not
/// exist, so a control that lived in it would be a control the phone build
/// does not have.
class TimerSidePanel extends ConsumerWidget {
  const TimerSidePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Padding(
      padding: EdgeInsets.only(top: Spacing.xxxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _LastSessionCard(),
          SizedBox(height: Spacing.md),
          _ShortcutsCard(),
        ],
      ),
    );
  }
}

class _LastSessionCard extends ConsumerWidget {
  const _LastSessionCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final holds = ref.watch(allHoldsProvider).valueOrNull ?? const [];
    final session = lastSession(holds);

    return _Card(
      title: l10n.timerSideLastSession,
      child: session == null
          ? Text(
              l10n.timerSideNoHistory,
              style: BreathLabTypography.micro.copyWith(color: c.textTertiary),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat.MMMd(
                    Localizations.localeOf(context).toString(),
                  ).format(session.date),
                  style: BreathLabTypography.micro.copyWith(
                    color: c.textSecondary,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      formatMmSs(session.best),
                      style: BreathLabTypography.displayMd.copyWith(
                        color: c.textPrimary,
                      ),
                    ),
                    const SizedBox(width: Spacing.sm),
                    Text(
                      l10n.timerSideSessionHolds(session.count),
                      style: BreathLabTypography.micro.copyWith(
                        color: c.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

/// The most recent training day before today, and what it contained.
///
/// Today is excluded on purpose: today's holds already have their own row
/// under the ring, and repeating them here would make the panel a second
/// opinion about the same numbers rather than context for them.
class LastSession {
  const LastSession({
    required this.date,
    required this.count,
    required this.best,
  });

  final DateTime date;
  final int count;
  final Duration best;
}

LastSession? lastSession(List<Hold> holds, {DateTime? now}) {
  final today = now ?? DateTime.now();
  DateTime? day;
  final durations = <Duration>[];

  // [allHoldsProvider] is newest-first, so the first max hold not from today
  // names the day, and everything after it on that day belongs to it.
  for (final hold in holds) {
    if (hold.type != HoldType.max) continue;
    final at = hold.createdAt;
    if (at.year == today.year &&
        at.month == today.month &&
        at.day == today.day) {
      continue;
    }
    final date = DateTime(at.year, at.month, at.day);
    day ??= date;
    if (date != day) break;
    durations.add(hold.duration);
  }

  if (day == null || durations.isEmpty) return null;
  return LastSession(
    date: day,
    count: durations.length,
    best: durations.reduce((a, b) => a > b ? a : b),
  );
}

class _ShortcutsCard extends StatelessWidget {
  const _ShortcutsCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Only where there is a keyboard to press. The slot itself is
    // desktop-width, but a wide window is not a keyboard.
    final hasKeyboard = switch (Theme.of(context).platform) {
      TargetPlatform.android || TargetPlatform.iOS => false,
      _ => true,
    };
    if (!hasKeyboard) return const SizedBox.shrink();

    return _Card(
      title: l10n.timerSideShortcuts,
      child: Column(
        children: [
          _Shortcut(keyLabel: 'Space', action: l10n.timerSideShortcutStart),
          _Shortcut(keyLabel: 'C', action: l10n.timerSideShortcutContraction),
          _Shortcut(keyLabel: 'Esc', action: l10n.timerSideShortcutCancel),
        ],
      ),
    );
  }
}

class _Shortcut extends StatelessWidget {
  const _Shortcut({required this.keyLabel, required this.action});

  final String keyLabel;
  final String action;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm),
      child: Row(
        children: [
          Container(
            width: 44,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: Spacing.xxs),
            // A keycap is nested inside a card, which is what an inset is.
            decoration: Surfaces.inset(context),
            child: Text(
              keyLabel,
              style: BreathLabTypography.section.copyWith(
                color: c.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(
              action,
              style: BreathLabTypography.micro.copyWith(color: c.textTertiary),
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      // Quiet, not primary: the Timer screen's subject is the ring, and
      // Design Revision §2 gives it no primary panel at all.
      decoration: Surfaces.quietPanel(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: BreathLabTypography.section.copyWith(color: c.textTertiary),
          ),
          const SizedBox(height: Spacing.sm),
          child,
        ],
      ),
    );
  }
}
