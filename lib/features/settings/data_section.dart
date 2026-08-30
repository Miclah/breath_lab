import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/db/database_provider.dart';
import '../../data/repositories/holds_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/table_sessions_repository.dart';
import '../../data/repositories/tags_repository.dart';
import '../../domain/models/sync_payload.dart';
import '../../domain/services/sync_service.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import '../safety/safety_provider.dart';
import '../sync/lan_sync_host_screen.dart';
import '../sync/lan_sync_providers.dart';
import '../sync/lan_sync_scan_screen.dart';
import 'theme_mode_provider.dart';

/// Settings → Data section: editable device name, last-sync status,
/// export/import of a `.blab` backup file, and the full reset. Doubles as
/// cross-device sync and as backup/restore — see
/// `docs/phases/PHASE_2A_sync.md`.
class DataSection extends StatelessWidget {
  const DataSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DeviceNameField(),
        _LastSyncRow(),
        _ExportImportButtons(),
        // Set apart by a divider and the full section gap: it belongs in
        // this section, and it does not belong within a thumb's travel of
        // the Export button people press routinely.
        SizedBox(height: Spacing.xxl),
        Divider(height: 0.5),
        _ResetAllDataRow(),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Reset all data
// ---------------------------------------------------------------------------

/// The one destructive action in Settings.
///
/// Keeps the full danger fill nowhere near it: the row is a label in danger
/// text, and the irreversible part is behind the confirmation dialog.
class _ResetAllDataRow extends ConsumerWidget {
  const _ResetAllDataRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      title: Text(
        l10n.settingsResetLabel,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: c.dangerText),
      ),
      subtitle: Text(
        l10n.settingsResetSubtitle,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: c.textTertiary),
      ),
      onTap: () => _confirmReset(context, ref),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.settingsResetConfirmTitle),
        content: Text(l10n.settingsResetConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.historyCancelButton),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.settingsResetButton),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(databaseProvider).resetAllData();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Deliberately *not* invalidating databaseProvider: that disposes the
    // AppDatabase and immediately builds a second one over the same file
    // while the first connection is still closing, which drift warns about
    // ("database was opened a second time") and which can leave the new
    // connection stale or locked. resetAllData() already emptied and
    // re-seeded every table, so the existing connection is correct — only
    // the things that cached its contents need to re-read.
    ref.invalidate(settingsRepositoryProvider);
    ref.invalidate(allHoldsProvider);
    ref.invalidate(allTableSessionsProvider);
    ref.invalidate(holdTagIdsProvider);
    ref.invalidate(holdTagCountsProvider);
    ref.invalidate(builtInTagsProvider);
    ref.invalidate(themeModeProvider);
    ref.invalidate(safetyAcknowledgedProvider);
  }
}

// ---------------------------------------------------------------------------
// Device name — editable text field
// ---------------------------------------------------------------------------

class _DeviceNameField extends ConsumerStatefulWidget {
  const _DeviceNameField();

  @override
  ConsumerState<_DeviceNameField> createState() => _DeviceNameFieldState();
}

class _DeviceNameFieldState extends ConsumerState<_DeviceNameField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String? _loaded;

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

  Future<void> _submit() async {
    final value = _controller.text.trim();
    if (value.isEmpty || value == _loaded) return;
    await ref.read(deviceNameProvider.notifier).set(value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final nameAsync = ref.watch(deviceNameProvider);

    nameAsync.whenData((name) {
      if (name != _loaded && !_focusNode.hasFocus) {
        _loaded = name;
        _controller.text = name;
      }
    });

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.lg,
        vertical: Spacing.sm,
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        decoration: InputDecoration(labelText: l10n.settingsDeviceNameLabel),
        onSubmitted: (_) => _submit(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Last sync status line
// ---------------------------------------------------------------------------

class _LastSyncRow extends ConsumerWidget {
  const _LastSyncRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final info = ref.watch(lastSyncInfoProvider).valueOrNull;

    final text = info == null
        ? l10n.settingsLastSyncNever
        : l10n.settingsLastSyncWith(
            DateFormat(
              'd MMM HH:mm',
            ).format(DateTime.fromMillisecondsSinceEpoch(info.atMs)),
            info.peerDeviceName,
          );

    return Padding(
      padding: const EdgeInsets.fromLTRB(Spacing.lg, 0, Spacing.lg, Spacing.sm),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: c.textTertiary),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Export / share / import buttons
// ---------------------------------------------------------------------------

class _ExportImportButtons extends ConsumerStatefulWidget {
  const _ExportImportButtons();

  @override
  ConsumerState<_ExportImportButtons> createState() =>
      _ExportImportButtonsState();
}

class _ExportImportButtonsState extends ConsumerState<_ExportImportButtons> {
  bool _busy = false;

  Future<void> _export() async {
    if (_busy) return;
    setState(() => _busy = true);
    final l10n = AppLocalizations.of(context)!;
    try {
      final service = await ref.read(syncServiceProvider.future);
      final path = await service.exportToFile();
      if (!mounted || path == null) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(l10n.settingsExportSuccess)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(l10n.settingsExportFailed)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _share() async {
    if (_busy) return;
    setState(() => _busy = true);
    final l10n = AppLocalizations.of(context)!;
    try {
      final service = await ref.read(syncServiceProvider.future);
      await service.shareExport();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(l10n.settingsExportFailed)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    if (_busy) return;
    setState(() => _busy = true);
    final l10n = AppLocalizations.of(context)!;
    try {
      final service = await ref.read(syncServiceProvider.future);
      final summary = await service.importFromFile();
      if (!mounted || summary == null) return;
      invalidateAfterSync(ref);
      await _showMessageDialog(
        title: l10n.settingsImportSummaryTitle,
        body: l10n.settingsImportSummaryBody(
          summary.counts.holdsAdded,
          summary.counts.sessionsAdded,
          summary.counts.holdsUpdated,
          summary.peerDeviceName,
        ),
      );
    } on SyncPayloadException catch (e) {
      if (!mounted) return;
      await _showMessageDialog(
        title: l10n.settingsImportFailedTitle,
        body: switch (e.reason) {
          SyncPayloadErrorReason.malformed =>
            l10n.settingsImportFailedMalformed,
          SyncPayloadErrorReason.unsupportedFormat =>
            l10n.settingsImportFailedFormat,
          SyncPayloadErrorReason.newerSchema => l10n.settingsImportFailedSchema,
        },
      );
    } catch (_) {
      if (!mounted) return;
      await _showMessageDialog(
        title: l10n.settingsImportFailedTitle,
        body: l10n.settingsImportFailedGeneric,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _showMessageDialog({
    required String title,
    required String body,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.historyDetailClose),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.lg,
        Spacing.sm,
        Spacing.lg,
        Spacing.lg,
      ),
      child: Wrap(
        spacing: Spacing.sm,
        runSpacing: Spacing.sm,
        children: [
          OutlinedButton(
            onPressed: _busy ? null : _export,
            child: Text(l10n.settingsExportButton),
          ),
          if (Platform.isAndroid)
            OutlinedButton(
              onPressed: _busy ? null : _share,
              child: Text(l10n.settingsShareButton),
            ),
          OutlinedButton(
            onPressed: _busy ? null : _import,
            child: Text(l10n.settingsImportButton),
          ),
          OutlinedButton(
            onPressed: _busy ? null : _syncOverWifi,
            child: Text(l10n.lanSyncEntryButton),
          ),
        ],
      ),
    );
  }

  void _syncOverWifi() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Platform.isAndroid
            ? const LanSyncScanScreen()
            : const LanSyncHostScreen(),
      ),
    );
  }
}
