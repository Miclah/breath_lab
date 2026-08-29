import 'package:flutter/material.dart' hide Durations;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/imst_sessions_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../domain/models/evidence_tier.dart';
import '../../domain/models/imst_session.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/global_messenger.dart';
import '../../shared/widgets/adaptive_page.dart';
import '../../shared/widgets/primary_action.dart';
import '../../shared/widgets/tier_badge.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';

/// Logs one IMST session — a breath count against the daily target and the
/// resistance level used.
///
/// Deliberately not a guided timer: IMST is 30 resisted breaths taken at the
/// user's own pace against a spring, not something a metronome should drive.
class ImstLogScreen extends ConsumerStatefulWidget {
  const ImstLogScreen({super.key});

  @override
  ConsumerState<ImstLogScreen> createState() => _ImstLogScreenState();
}

class _ImstLogScreenState extends ConsumerState<ImstLogScreen> {
  int _breaths = 0;
  int? _level;
  bool _saving = false;

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final repo = await ref.read(imstSessionsRepositoryProvider.future);
      final name = await ref.read(imstDeviceNameProvider.future);
      final pimax = await ref.read(imstPimaxCmH2OProvider.future);
      final level = _level ?? await ref.read(imstDeviceLevelProvider.future);
      final now = DateTime.now();
      await repo.save(
        ImstSession(
          id: repo.newId(),
          createdAt: now,
          updatedAt: now,
          deviceId: '',
          breaths: _breaths,
          deviceName: name,
          deviceLevel: level,
          pimaxCmH2O: pimax,
        ),
      );
      ref.invalidate(allImstSessionsProvider);
    } catch (error, stack) {
      debugPrint('Failed to save IMST session: $error\n$stack');
      if (mounted) setState(() => _saving = false);
      _report((l10n) => l10n.imstLogSaveFailed);
      return;
    }
    if (!mounted) return;
    _report((l10n) => l10n.imstLogSaved);
    Navigator.of(context).pop();
  }

  void _report(String Function(AppLocalizations) message) {
    final messenger = scaffoldMessengerKey.currentState;
    final ctx = messenger?.context;
    if (messenger == null || ctx == null) return;
    final l10n = AppLocalizations.of(ctx);
    if (l10n == null) return;
    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message(l10n))));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final target = ref.watch(imstTargetBreathsProvider).valueOrNull ?? 30;
    final settingsLevel = ref.watch(imstDeviceLevelProvider).valueOrNull ?? 3;
    // Seeded from settings until the user adjusts it here for this session.
    final level = _level ?? settingsLevel;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.imstLogTitle)),
      body: SafeArea(
        child: AdaptivePage(
          maxWidth: ContentWidth.reading,
          centerVertically: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text(
                  l10n.imstLogBreathsLabel.toUpperCase(),
                  style: BreathLabTypography.section.copyWith(
                    color: c.textTertiary,
                  ),
                ),
              ),
              const SizedBox(height: Spacing.sm),
              _BreathCounter(
                breaths: _breaths,
                target: target,
                onChanged: (v) => setState(() => _breaths = v),
              ),
              const SizedBox(height: Spacing.xxl),
              _LevelRow(
                level: level,
                onChanged: (v) => setState(() => _level = v),
              ),
              const SizedBox(height: Spacing.xxl),
              const Center(child: TierBadge(EvidenceTier.strong)),
              const SizedBox(height: Spacing.sm),
              Text(
                l10n.imstLogEvidenceNote,
                textAlign: TextAlign.center,
                style: BreathLabTypography.micro.copyWith(
                  color: c.textTertiary,
                ),
              ),
              const SizedBox(height: Spacing.xxl),
              PrimaryAction(
                child: FilledButton(
                  onPressed: _saving || _breaths == 0 ? null : _save,
                  child: Text(l10n.imstLogSave),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BreathCounter extends StatelessWidget {
  const _BreathCounter({
    required this.breaths,
    required this.target,
    required this.onChanged,
  });

  final int breaths;
  final int target;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final reachedTarget = breaths >= target;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton.filledTonal(
              onPressed: breaths > 0 ? () => onChanged(breaths - 1) : null,
              icon: const Icon(Icons.remove),
            ),
            const SizedBox(width: Spacing.xl),
            Text(
              '$breaths',
              style: BreathLabTypography.displayMd.copyWith(
                color: reachedTarget ? c.primaryText : c.textPrimary,
              ),
            ),
            const SizedBox(width: Spacing.xl),
            IconButton.filledTonal(
              onPressed: () => onChanged(breaths + 1),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          l10n.imstLogBreathsOfTarget(target),
          style: BreathLabTypography.micro.copyWith(color: c.textTertiary),
        ),
      ],
    );
  }
}

class _LevelRow extends StatelessWidget {
  const _LevelRow({required this.level, required this.onChanged});

  final int level;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;

    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.imstLogLevelLabel,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        IconButton.filledTonal(
          onPressed: level > 1 ? () => onChanged(level - 1) : null,
          icon: const Icon(Icons.remove),
        ),
        SizedBox(
          width: 44,
          child: Text(
            '$level',
            textAlign: TextAlign.center,
            style: BreathLabTypography.numericMd.copyWith(color: c.textPrimary),
          ),
        ),
        IconButton.filledTonal(
          onPressed: level < 12 ? () => onChanged(level + 1) : null,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
