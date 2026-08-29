import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/widgets/adaptive_page.dart';
import '../../theme/tokens.dart';
import 'safety_provider.dart';

class SafetyScreen extends ConsumerWidget {
  const SafetyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.lg),
          child: AdaptivePage(
            maxWidth: ContentWidth.reading,
            padding: EdgeInsets.zero,
            centerVertically: true,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: Spacing.xl),
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 56,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: Spacing.md),
                  Text(
                    l10n.safetyTitle,
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Spacing.sm),
                  Text(
                    l10n.safetyDescription,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: Spacing.xl),
                  _SafetyRule(icon: Icons.block, text: l10n.safetyRule1),
                  const SizedBox(height: Spacing.md),
                  _SafetyRule(icon: Icons.block, text: l10n.safetyRule2),
                  const SizedBox(height: Spacing.md),
                  _SafetyRule(
                    icon: Icons.pan_tool_outlined,
                    text: l10n.safetyRule3,
                  ),
                  const SizedBox(height: Spacing.md),
                  _SafetyRule(
                    icon: Icons.people_outline,
                    text: l10n.safetyRuleBuddy,
                  ),
                  const SizedBox(height: Spacing.md),
                  _SafetyRule(
                    icon: Icons.medical_information_outlined,
                    text: l10n.safetyRuleMedical,
                  ),
                  const SizedBox(height: Spacing.md),
                  _SafetyRule(icon: Icons.block, text: l10n.safetyRulePacking),
                  const SizedBox(height: Spacing.xl),
                  FilledButton(
                    onPressed: () {
                      // Pushed from Settings (already acknowledged) — just go
                      // back. Otherwise this is the first-launch gate, where
                      // acknowledging is what dismisses it.
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        ref
                            .read(safetyAcknowledgedProvider.notifier)
                            .acknowledge();
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
                      child: Text(l10n.safetyAcknowledge),
                    ),
                  ),
                  const SizedBox(height: Spacing.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SafetyRule extends StatelessWidget {
  const _SafetyRule({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.error),
        const SizedBox(width: Spacing.sm),
        Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
      ],
    );
  }
}
