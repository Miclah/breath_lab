import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import '../report/report_reader_screen.dart';
import '../safety/safety_screen.dart';

final _packageInfoProvider = FutureProvider<PackageInfo>((ref) {
  return PackageInfo.fromPlatform();
});

/// Settings → About section: safety information and the app version.
///
/// `Reset all data` used to live here, one row below the version number and
/// two rows from nothing else destructive. It belongs with the other things
/// that act on the user's data — see `DataSection`.
class AboutSection extends ConsumerWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;
    final packageInfo = ref.watch(_packageInfoProvider).valueOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          title: Text(l10n.settingsResearchSummaryLink),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const ReportReaderScreen())),
        ),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          title: Text(l10n.settingsSafetyInfoLink),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const SafetyScreen())),
        ),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          title: Text(l10n.settingsVersionLabel),
          trailing: Text(
            packageInfo == null
                ? ''
                : '${packageInfo.version} (${packageInfo.buildNumber})',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: c.textSecondary),
          ),
        ),
      ],
    );
  }
}
