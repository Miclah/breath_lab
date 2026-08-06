import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/db/database_provider.dart';
import '../../data/repositories/holds_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/table_sessions_repository.dart';
import '../../data/repositories/tags_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import '../safety/safety_provider.dart';
import '../safety/safety_screen.dart';
import 'theme_mode_provider.dart';

final _packageInfoProvider = FutureProvider<PackageInfo>((ref) {
  return PackageInfo.fromPlatform();
});

/// Settings → About section: safety info link, app version, and a full
/// data reset (behind a confirmation dialog).
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
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          title: Text(
            l10n.settingsResetLabel,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: c.danger),
          ),
          onTap: () => _confirmReset(context, ref),
        ),
      ],
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
