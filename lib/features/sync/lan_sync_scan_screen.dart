import 'package:flutter/material.dart' hide Durations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../domain/models/lan_pairing.dart';
import '../../domain/services/lan_sync_client.dart';
import '../../domain/services/sync_service.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import 'lan_sync_providers.dart';

/// Android side of QR-paired LAN sync: point the camera at the code on the
/// PC, then run the exchange.
class LanSyncScanScreen extends ConsumerStatefulWidget {
  const LanSyncScanScreen({super.key});

  @override
  ConsumerState<LanSyncScanScreen> createState() => _LanSyncScanScreenState();
}

enum _Phase { scanning, exchanging, done, failed }

class _LanSyncScanScreenState extends ConsumerState<LanSyncScanScreen> {
  final _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  _Phase _phase = _Phase.scanning;
  String _message = '';
  SyncImportSummary? _summary;
  bool _handling = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handling || _phase != _Phase.scanning) return;
    final raw = capture.barcodes
        .map((b) => b.rawValue)
        .firstWhere((v) => v != null && v.isNotEmpty, orElse: () => null);
    if (raw == null) return;

    final LanPairing pairing;
    try {
      pairing = LanPairing.decode(raw);
    } on LanPairingException catch (e) {
      if (e.reason == LanPairingErrorReason.notBreathLab) return;
      _fail(
        e.reason == LanPairingErrorReason.unsupportedVersion
            ? e.message
            : AppLocalizations.of(context)!.lanSyncScanNotRecognised,
      );
      return;
    }

    _handling = true;
    await _controller.stop();
    setState(() => _phase = _Phase.exchanging);

    try {
      final service = await ref.read(syncServiceProvider.future);
      final summary = await LanSyncClient(service).exchange(pairing);
      if (!mounted) return;
      invalidateAfterSync(ref);
      setState(() {
        _phase = _Phase.done;
        _summary = summary;
      });
    } on LanSyncClientException catch (e) {
      _fail(e.message);
    } catch (_) {
      if (mounted) _fail(AppLocalizations.of(context)!.lanSyncFailedGeneric);
    }
  }

  void _fail(String message) {
    if (!mounted) return;
    setState(() {
      _phase = _Phase.failed;
      _message = message;
    });
  }

  Future<void> _restart() async {
    _handling = false;
    setState(() => _phase = _Phase.scanning);
    await _controller.start();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.lanSyncTitle)),
      body: SafeArea(
        child: switch (_phase) {
          _Phase.scanning => _Viewfinder(
            controller: _controller,
            onDetect: _onDetect,
          ),
          _Phase.exchanging => _Centred(
            child: _Busy(text: l10n.lanSyncExchanging),
          ),
          _Phase.done => _Centred(child: _Done(summary: _summary!)),
          _Phase.failed => _Centred(
            child: _Failed(message: _message, onRetry: _restart),
          ),
        },
      ),
    );
  }
}

class _Viewfinder extends StatelessWidget {
  const _Viewfinder({required this.controller, required this.onDetect});
  final MobileScannerController controller;
  final void Function(BarcodeCapture) onDetect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Stack(
      fit: StackFit.expand,
      children: [
        MobileScanner(
          controller: controller,
          onDetect: onDetect,
          errorBuilder: (context, error) =>
              _Centred(child: _CameraError(error: error)),
        ),
        // A framed cut-out and the instruction, so it reads as "aim here".
        IgnorePointer(
          child: Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(Radius.lg),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: Spacing.xxl,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.lg,
                vertical: Spacing.sm,
              ),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(Radius.pill),
              ),
              child: Text(
                l10n.lanSyncScanInstruction,
                style: BreathLabTypography.body.copyWith(color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CameraError extends StatelessWidget {
  const _CameraError({required this.error});
  final MobileScannerException error;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final denied = error.errorCode == MobileScannerErrorCode.permissionDenied;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.no_photography_outlined, size: 40, color: c.textTertiary),
        const SizedBox(height: Spacing.lg),
        Text(
          denied
              ? l10n.lanSyncCameraPermissionTitle
              : l10n.lanSyncFailedGeneric,
          textAlign: TextAlign.center,
          style: BreathLabTypography.title.copyWith(color: c.textPrimary),
        ),
        if (denied) ...[
          const SizedBox(height: Spacing.sm),
          Text(
            l10n.lanSyncCameraPermissionBody,
            textAlign: TextAlign.center,
            style: BreathLabTypography.body.copyWith(color: c.textSecondary),
          ),
        ],
      ],
    );
  }
}

class _Centred extends StatelessWidget {
  const _Centred({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 380),
      child: Padding(padding: const EdgeInsets.all(Spacing.xxl), child: child),
    ),
  );
}

class _Busy extends StatelessWidget {
  const _Busy({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: Spacing.lg),
        Text(
          text,
          textAlign: TextAlign.center,
          style: BreathLabTypography.body.copyWith(color: c.textSecondary),
        ),
      ],
    );
  }
}

class _Done extends StatelessWidget {
  const _Done({required this.summary});
  final SyncImportSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.check_circle_outline, size: 48, color: c.primary),
        const SizedBox(height: Spacing.lg),
        Text(
          l10n.lanSyncDoneTitle,
          textAlign: TextAlign.center,
          style: BreathLabTypography.title.copyWith(color: c.textPrimary),
        ),
        const SizedBox(height: Spacing.sm),
        Text(
          l10n.settingsImportSummaryBody(
            summary.counts.holdsAdded,
            summary.counts.sessionsAdded,
            summary.counts.holdsUpdated,
            summary.peerDeviceName,
          ),
          textAlign: TextAlign.center,
          style: BreathLabTypography.body.copyWith(color: c.textSecondary),
        ),
        const SizedBox(height: Spacing.xl),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.historyDetailClose),
        ),
      ],
    );
  }
}

class _Failed extends StatelessWidget {
  const _Failed({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.error_outline, size: 40, color: c.dangerText),
        const SizedBox(height: Spacing.lg),
        Text(
          message,
          textAlign: TextAlign.center,
          style: BreathLabTypography.body.copyWith(color: c.textSecondary),
        ),
        const SizedBox(height: Spacing.xl),
        FilledButton(onPressed: onRetry, child: Text(l10n.lanSyncRetry)),
        const SizedBox(height: Spacing.sm),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.historyDetailClose),
        ),
      ],
    );
  }
}
