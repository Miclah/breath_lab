import 'package:flutter/material.dart' hide Durations;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/holds_repository.dart';
import '../../domain/models/evidence_tier.dart';
import '../../domain/models/hold.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/global_messenger.dart';
import '../../shared/widgets/tier_badge.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';

/// The non-timed session kinds this sheet can log: a rest day (a positively
/// counted event, per `RESEARCH_ALIGNMENT.md` §3) and a chest-wall
/// stretching session (tier B, single-digit-percent VC gains at best).
enum LoggableSession { rest, stretch }

extension _SessionType on LoggableSession {
  HoldType get holdType => switch (this) {
    LoggableSession.rest => HoldType.rest,
    LoggableSession.stretch => HoldType.stretch,
  };

  EvidenceTier get tier => switch (this) {
    LoggableSession.rest => EvidenceTier.mechanistic,
    LoggableSession.stretch => EvidenceTier.mechanistic,
  };

  String title(AppLocalizations l10n) => switch (this) {
    LoggableSession.rest => l10n.logRestTitle,
    LoggableSession.stretch => l10n.logStretchTitle,
  };

  String blurb(AppLocalizations l10n) => switch (this) {
    LoggableSession.rest => l10n.logRestBlurb,
    LoggableSession.stretch => l10n.logStretchBlurb,
  };

  String saved(AppLocalizations l10n) => switch (this) {
    LoggableSession.rest => l10n.logRestSaved,
    LoggableSession.stretch => l10n.logStretchSaved,
  };
}

void showLogSessionSheet(BuildContext context, LoggableSession kind) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => _LogSessionSheet(kind: kind),
  );
}

class _LogSessionSheet extends ConsumerStatefulWidget {
  const _LogSessionSheet({required this.kind});

  final LoggableSession kind;

  @override
  ConsumerState<_LogSessionSheet> createState() => _LogSessionSheetState();
}

class _LogSessionSheetState extends ConsumerState<_LogSessionSheet> {
  bool _saving = false;

  Future<void> _save() async {
    if (_saving) return;
    final kind = widget.kind;
    // Captured before the first await so no BuildContext crosses the gap.
    final savedMessage = kind.saved(AppLocalizations.of(context)!);
    setState(() => _saving = true);
    try {
      final repo = await ref.read(holdsRepositoryProvider.future);
      final now = DateTime.now();
      await repo.save(
        Hold(
          id: repo.newId(),
          createdAt: now,
          updatedAt: now,
          deviceId: '',
          // A rest or stretch day is an event, not a timed effort.
          duration: Duration.zero,
          type: kind.holdType,
          lungVolume: LungVolume.full,
          isPb: false,
        ),
      );
      ref.invalidate(allHoldsProvider);
    } catch (error, stack) {
      debugPrint('Failed to log ${kind.name}: $error\n$stack');
      if (mounted) setState(() => _saving = false);
      return;
    }
    scaffoldMessengerKey.currentState
      ?..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(savedMessage)));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final kind = widget.kind;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              kind.title(l10n),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              kind.blurb(l10n),
              style: BreathLabTypography.body.copyWith(color: c.textSecondary),
            ),
            const SizedBox(height: Spacing.md),
            TierBadge(kind.tier),
            const SizedBox(height: Spacing.xl),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _saving
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: Text(l10n.historyCancelButton),
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: FilledButton(
                    onPressed: _saving ? null : _save,
                    child: Text(l10n.logSessionConfirm),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
