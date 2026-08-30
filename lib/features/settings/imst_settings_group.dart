import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/settings_repository.dart';
import '../../domain/models/evidence_tier.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/contextual_tip.dart';
import '../../shared/widgets/tier_badge.dart';
import '../report/report_anchor.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import 'settings_stepper.dart';

/// Settings → Training: the IMST configuration group.
///
/// Per `PHASE_3D_research.md`, no PImax is inferred from the dial. The app
/// records the resistance level the user actually set plus an optional
/// measured PImax; progression advice elsewhere is relative to that level.
class ImstSettingsGroup extends StatelessWidget {
  const ImstSettingsGroup({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.settingsImstGroupLabel,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            const TierBadge(EvidenceTier.strong, compact: true),
          ],
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          l10n.settingsImstIntro,
          style: BreathLabTypography.micro.copyWith(color: c.textTertiary),
        ),
        const SizedBox(height: Spacing.lg),
        const _ImstDeviceNameField(),
        const SizedBox(height: Spacing.lg),
        const _ImstLevelStepper(),
        const SizedBox(height: Spacing.md),
        const _ImstTargetStepper(),
        const SizedBox(height: Spacing.md),
        const _ImstPimaxStepper(),
        const SizedBox(height: Spacing.xs),
        ContextualTip(
          text: l10n.settingsImstPimaxNote,
          anchor: ReportAnchor.imst,
          style: BreathLabTypography.micro.copyWith(color: c.textTertiary),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _ImstDeviceNameField extends ConsumerStatefulWidget {
  const _ImstDeviceNameField();

  @override
  ConsumerState<_ImstDeviceNameField> createState() =>
      _ImstDeviceNameFieldState();
}

class _ImstDeviceNameFieldState extends ConsumerState<_ImstDeviceNameField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _seeded = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        ref.read(imstDeviceNameProvider.notifier).set(_controller.text.trim());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;

    ref.watch(imstDeviceNameProvider).whenData((name) {
      if (!_seeded && !_focusNode.hasFocus) {
        _seeded = true;
        _controller.text = name ?? '';
      }
    });

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(Radius.sm),
      borderSide: BorderSide(color: c.border, width: 0.5),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.settingsImstDeviceNameLabel,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: Spacing.sm),
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          style: BreathLabTypography.body.copyWith(color: c.textPrimary),
          decoration: InputDecoration(
            hintText: l10n.settingsImstDeviceNameHint,
            hintStyle: BreathLabTypography.body.copyWith(color: c.textTertiary),
            filled: true,
            fillColor: c.insetFill,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.md,
            ),
            border: border,
            enabledBorder: border,
            focusedBorder: border.copyWith(
              borderSide: BorderSide(color: c.primary, width: 0.5),
            ),
          ),
          onSubmitted: (value) =>
              ref.read(imstDeviceNameProvider.notifier).set(value.trim()),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _ImstLevelStepper extends ConsumerWidget {
  const _ImstLevelStepper();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final level = ref.watch(imstDeviceLevelProvider).valueOrNull ?? 3;

    return SettingsStepper(
      label: l10n.settingsImstLevelLabel,
      value: level,
      min: 1,
      max: 12,
      step: 1,
      format: (v) => '$v',
      onChanged: (v) => ref.read(imstDeviceLevelProvider.notifier).set(v),
    );
  }
}

// ---------------------------------------------------------------------------

class _ImstTargetStepper extends ConsumerWidget {
  const _ImstTargetStepper();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final target = ref.watch(imstTargetBreathsProvider).valueOrNull ?? 30;

    return SettingsStepper(
      label: l10n.settingsImstTargetLabel,
      value: target,
      min: 10,
      max: 60,
      step: 5,
      format: (v) => '$v',
      onChanged: (v) => ref.read(imstTargetBreathsProvider.notifier).set(v),
    );
  }
}

// ---------------------------------------------------------------------------

class _ImstPimaxStepper extends ConsumerWidget {
  const _ImstPimaxStepper();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final pimax = ref.watch(imstPimaxCmH2OProvider).valueOrNull;

    return SettingsStepper(
      label: l10n.settingsImstPimaxLabel,
      value: pimax ?? 0,
      min: 0,
      max: 200,
      step: 5,
      // 0 reads as "not set" and writes null — PImax is genuinely optional.
      format: (v) => v == 0 ? '—' : '$v',
      onChanged: (v) =>
          ref.read(imstPimaxCmH2OProvider.notifier).set(v == 0 ? null : v),
    );
  }
}
