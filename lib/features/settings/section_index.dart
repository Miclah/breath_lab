import 'package:flutter/material.dart' hide Durations;

import '../../l10n/app_localizations.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';

/// One group of the settings form, declared once and rendered twice: as a
/// header plus body in the form, and as a row in the jump list.
///
/// Declaring the order in one list is the point. Before this the order lived
/// implicitly in the order of `ListView` children, so any index beside it
/// would be a second copy of that order, free to drift.
class SettingsSection {
  const SettingsSection({
    required this.anchor,
    required this.title,
    required this.body,
    this.visible = true,
  });

  /// Attached to the section's header in the form, and used to scroll to it.
  final GlobalKey anchor;

  final String title;
  final Widget body;

  /// Some sections only apply under a setting — the Timer section is
  /// meaningless unless prep is set to a breathing mode. Hidden here means
  /// hidden from the jump list too; a list that offers a destination the
  /// form does not contain is worse than no list.
  final bool visible;
}

/// The settings side column: a jump list.
///
/// This is the clearest case for the side slot in the whole app. A long
/// single-column form is exactly where a jump list earns its space, and it
/// fills the room with something that does work rather than something that
/// fills room.
///
/// It is never the only way to reach a section — scrolling always is — which
/// is what makes it safe to leave out entirely on a phone.
class SectionIndex extends StatelessWidget {
  const SectionIndex({super.key, required this.sections});

  final List<SettingsSection> sections;

  void _jumpTo(SettingsSection section) {
    final context = section.anchor.currentContext;
    if (context == null) return;
    Scrollable.ensureVisible(
      context,
      duration: Durations.slow,
      curve: Curves.easeOut,
      // Top-aligned: landing a section header halfway up the viewport reads
      // as having scrolled past it.
      alignment: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xl),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: Spacing.md, bottom: Spacing.sm),
          child: Text(
            AppLocalizations.of(context)!.settingsJumpTo.toUpperCase(),
            style: BreathLabTypography.section.copyWith(color: c.textTertiary),
          ),
        ),
        for (final section in sections.where((s) => s.visible))
          InkWell(
            onTap: () => _jumpTo(section),
            borderRadius: BorderRadius.circular(Radius.sm),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.md,
                vertical: Spacing.sm,
              ),
              child: Text(
                section.title,
                style: BreathLabTypography.body.copyWith(
                  color: c.textSecondary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
