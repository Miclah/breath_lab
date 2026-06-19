import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
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
              _SafetyRule(text: l10n.safetyRule1),
              const SizedBox(height: Spacing.md),
              _SafetyRule(text: l10n.safetyRule2),
              const SizedBox(height: Spacing.md),
              _SafetyRule(text: l10n.safetyRule3),
              const Spacer(),
              FilledButton(
                onPressed: () =>
                    ref.read(safetyAcknowledgedProvider.notifier).acknowledge(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
                  child: Text(l10n.safetyAcknowledge),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SafetyRule extends StatelessWidget {
  const _SafetyRule({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.block, size: 20, color: theme.colorScheme.error),
        const SizedBox(width: Spacing.sm),
        Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
      ],
    );
  }
}
