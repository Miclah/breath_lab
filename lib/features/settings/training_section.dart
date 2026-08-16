import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/settings_repository.dart';
import '../../domain/models/hold.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/format_duration.dart';
import '../../shared/widgets/segment_label.dart';
import '../../theme/tokens.dart';

/// Settings → Training section: current max, default prep mode, default
/// lung volume. All values are read from and written straight to
/// [SettingsRepository].
class TrainingSection extends StatelessWidget {
  const TrainingSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.lg,
        vertical: Spacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CurrentMaxField(),
          const SizedBox(height: Spacing.xl),
          Text(
            l10n.settingsDefaultPrepModeLabel,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: Spacing.sm),
          const _DefaultPrepModeSelector(),
          const SizedBox(height: Spacing.xl),
          Text(
            l10n.settingsDefaultLungVolumeLabel,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: Spacing.sm),
          const _DefaultLungVolumeSelector(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Current max — editable mm:ss field
// ---------------------------------------------------------------------------

class _CurrentMaxField extends ConsumerStatefulWidget {
  const _CurrentMaxField();

  @override
  ConsumerState<_CurrentMaxField> createState() => _CurrentMaxFieldState();
}

class _CurrentMaxFieldState extends ConsumerState<_CurrentMaxField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String? _error;
  int? _loadedMs;

  static final _pattern = RegExp(r'^(\d{1,2}):([0-5]\d)$');

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) _submit();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _format(int ms) => formatMmSs(Duration(milliseconds: ms));

  Future<void> _submit() async {
    final match = _pattern.firstMatch(_controller.text.trim());
    if (match == null) {
      setState(
        () => _error = AppLocalizations.of(context)!.settingsCurrentMaxInvalid,
      );
      return;
    }
    final minutes = int.parse(match.group(1)!);
    final seconds = int.parse(match.group(2)!);
    final ms = (minutes * 60 + seconds) * 1000;

    setState(() => _error = null);
    await ref.read(currentMaxMsProvider.notifier).set(ms);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentMaxAsync = ref.watch(currentMaxMsProvider);

    currentMaxAsync.whenData((ms) {
      if (ms != null && ms != _loadedMs && !_focusNode.hasFocus) {
        _loadedMs = ms;
        _controller.text = _format(ms);
      }
    });

    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: TextInputType.datetime,
      decoration: InputDecoration(
        labelText: l10n.settingsCurrentMaxLabel,
        hintText: 'mm:ss',
        errorText: _error,
      ),
      onSubmitted: (_) => _submit(),
    );
  }
}

// ---------------------------------------------------------------------------
// Default prep mode — 4-way toggle
// ---------------------------------------------------------------------------

class _DefaultPrepModeSelector extends ConsumerWidget {
  const _DefaultPrepModeSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selected =
        ref.watch(defaultPrepModeProvider).valueOrNull ?? PrepMode.threeSeconds;

    return SegmentedButton<PrepMode>(
      segments: [
        ButtonSegment(
          value: PrepMode.none,
          label: SegmentLabel(l10n.historyPrepModeNone),
        ),
        ButtonSegment(
          value: PrepMode.threeSeconds,
          label: SegmentLabel(l10n.historyPrepMode3s),
        ),
        ButtonSegment(
          value: PrepMode.short,
          label: SegmentLabel(l10n.historyPrepModeShort),
        ),
        ButtonSegment(
          value: PrepMode.full,
          label: SegmentLabel(l10n.historyPrepModeFull),
        ),
      ],
      selected: {selected},
      showSelectedIcon: false,
      onSelectionChanged: (value) =>
          ref.read(defaultPrepModeProvider.notifier).set(value.first),
    );
  }
}

// ---------------------------------------------------------------------------
// Default lung volume — 3-way toggle
// ---------------------------------------------------------------------------

class _DefaultLungVolumeSelector extends ConsumerWidget {
  const _DefaultLungVolumeSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selected =
        ref.watch(defaultLungVolumeProvider).valueOrNull ?? LungVolume.full;

    return SegmentedButton<LungVolume>(
      segments: [
        ButtonSegment(
          value: LungVolume.full,
          label: SegmentLabel(l10n.lungVolFull),
        ),
        ButtonSegment(
          value: LungVolume.frc,
          label: SegmentLabel(l10n.lungVolFrc),
        ),
        ButtonSegment(
          value: LungVolume.empty,
          label: SegmentLabel(l10n.lungVolEmpty),
        ),
      ],
      selected: {selected},
      showSelectedIcon: false,
      onSelectionChanged: (value) =>
          ref.read(defaultLungVolumeProvider.notifier).set(value.first),
    );
  }
}
