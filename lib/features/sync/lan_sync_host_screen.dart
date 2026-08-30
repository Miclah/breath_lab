import 'package:flutter/material.dart' hide Durations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../domain/services/lan_sync_host.dart';
import '../../domain/services/sync_service.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/adaptive_page.dart';
import '../../theme/colors.dart';
import '../../theme/surfaces.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import 'lan_sync_providers.dart';

/// Windows side of QR-paired LAN sync: shows a QR of the pairing and tracks
/// the exchange to completion.
class LanSyncHostScreen extends ConsumerWidget {
  const LanSyncHostScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final status = ref.watch(lanSyncHostStatusProvider);

    ref.listen(lanSyncHostStatusProvider, (_, next) {
      if (next.valueOrNull is LanSyncHostDone) invalidateAfterSync(ref);
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.lanSyncTitle)),
      body: SafeArea(
        child: AdaptivePage(
          maxWidth: ContentWidth.reading,
          centerVertically: true,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: Spacing.xxl),
                child: status.when(
                  loading: () => _Message(text: l10n.lanSyncHostStarting),
                  error: (error, _) => _Failed(
                    message: error is LanSyncHostException
                        ? error.message
                        : l10n.lanSyncFailedGeneric,
                    onRetry: () => ref.invalidate(lanSyncHostStatusProvider),
                  ),
                  data: (state) => switch (state) {
                    LanSyncServing(:final pairing) => _Serving(
                      code: pairing.encode(),
                    ),
                    LanSyncExchanging() => _Message(
                      text: l10n.lanSyncExchanging,
                    ),
                    LanSyncHostDone(:final summary) => _Done(summary: summary),
                    LanSyncHostFailed(:final message) => _Failed(
                      message: message,
                      onRetry: () => ref.invalidate(lanSyncHostStatusProvider),
                    ),
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Serving extends StatelessWidget {
  const _Serving({required this.code});
  final String code;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.lanSyncHostInstruction,
          textAlign: TextAlign.center,
          style: BreathLabTypography.body.copyWith(color: c.textSecondary),
        ),
        const SizedBox(height: Spacing.xl),
        // The QR is always dark-on-white regardless of theme, or a scanner
        // in a dim room cannot read it.
        Center(
          child: Container(
            padding: const EdgeInsets.all(Spacing.lg),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(Radius.lg),
            ),
            child: QrImageView(
              data: code,
              size: 240,
              backgroundColor: const Color(0xFFFFFFFF),
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Color(0xFF0A0E14),
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Color(0xFF0A0E14),
              ),
            ),
          ),
        ),
        const SizedBox(height: Spacing.xl),
        Container(
          padding: const EdgeInsets.all(Spacing.md),
          decoration: Surfaces.quietPanel(context),
          child: Column(
            children: [
              Text(
                l10n.lanSyncPlaintextNotice,
                textAlign: TextAlign.center,
                style: BreathLabTypography.micro.copyWith(
                  color: c.textTertiary,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                l10n.lanSyncFirewallHint,
                textAlign: TextAlign.center,
                style: BreathLabTypography.micro.copyWith(
                  color: c.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text});
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
