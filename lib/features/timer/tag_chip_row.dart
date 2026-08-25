import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart' hide Durations;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/tags_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/horizontal_scroll_fade.dart';
import '../../theme/breakpoints.dart';
import '../../theme/colors.dart';
import '../../theme/tokens.dart';
import 'providers.dart';

/// Maps a tag's [labelKey] to its display string.
String _tagLabel(String labelKey, AppLocalizations l10n) => switch (labelKey) {
  'tag.tired' => l10n.tagTired,
  'tag.wellRested' => l10n.tagWellRested,
  'tag.fullStomach' => l10n.tagFullStomach,
  'tag.emptyStomach' => l10n.tagEmptyStomach,
  'tag.anxious' => l10n.tagAnxious,
  'tag.greatPrep' => l10n.tagGreatPrep,
  'tag.samba' => l10n.tagSamba,
  'tag.cold' => l10n.tagCold,
  'tag.hot' => l10n.tagHot,
  String s when s.startsWith('custom:') => s.substring(7),
  _ => labelKey,
};

/// Built-in tag chips plus a custom "+ Add tag" chip, wired to
/// [selectedTagIdsProvider] and [pendingCustomTagsProvider].
///
/// Two layouts, because one does not serve both widths. On a phone the chips
/// scroll sideways behind an edge fade — vertical space on the result screen
/// is scarce and nine tags would take three rows of it. Where the column is
/// wider than a phone they wrap instead: there is room for two rows, and a
/// wrapped row shows every tag at once rather than hiding most of them behind
/// a gesture.
///
/// The edge fade is only drawn on the scrolling layout. Painted over a row
/// that does not scroll it is not an affordance, it is a chip with its last
/// syllable faded out — which is what "Great p…" was.
class TagChipRow extends ConsumerWidget {
  const TagChipRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final tagsAsync = ref.watch(builtInTagsProvider);
    final selectedIds = ref.watch(selectedTagIdsProvider);
    final pending = ref.watch(pendingCustomTagsProvider);

    final tags = tagsAsync.valueOrNull ?? [];

    final chips = <Widget>[
      for (final tag in tags)
        _TagChip(
          label: _tagLabel(tag.labelKey, l10n),
          selected: selectedIds.contains(tag.id),
          onTap: () {
            final current = ref.read(selectedTagIdsProvider);
            final next = Set<String>.from(current);
            if (current.contains(tag.id)) {
              next.remove(tag.id);
            } else {
              next.add(tag.id);
            }
            ref.read(selectedTagIdsProvider.notifier).state = next;
          },
        ),
      for (final text in pending)
        _TagChip(label: text, selected: true, onTap: null),
      _AddTagChip(
        onAdd: (text) {
          ref.read(pendingCustomTagsProvider.notifier).state = [
            ...ref.read(pendingCustomTagsProvider),
            text,
          ];
        },
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        if (!Breakpoint.forWidth(constraints.maxWidth).isCompact) {
          return Wrap(
            spacing: Spacing.xs,
            runSpacing: Spacing.xs,
            children: chips,
          );
        }

        // Flutter's default dragDevices omit the mouse, so this row could not
        // be scrolled at all on desktop and any tag past the right edge was
        // unreachable.
        return ScrollConfiguration(
          behavior: const _DragScrollBehavior(),
          child: HorizontalScrollFade(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
              child: Row(
                children: [
                  for (final (i, chip) in chips.indexed) ...[
                    if (i > 0) const SizedBox(width: Spacing.xs),
                    chip,
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Scroll behavior that also accepts mouse and trackpad drags, for
/// horizontal strips that have no other way to be scrolled on desktop.
class _DragScrollBehavior extends MaterialScrollBehavior {
  const _DragScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.stylus,
    PointerDeviceKind.invertedStylus,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.mouse,
  };
}

// ---------------------------------------------------------------------------
// Single chip
// ---------------------------------------------------------------------------

class _TagChip extends StatefulWidget {
  const _TagChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  State<_TagChip> createState() => _TagChipState();
}

class _TagChipState extends State<_TagChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final selected = widget.selected;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: Durations.fast,
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.xxs,
          ),
          decoration: BoxDecoration(
            color: selected ? c.primarySurface : Colors.transparent,
            border: Border.all(
              color: selected ? c.primary : c.border,
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 13,
              color: selected ? c.primaryText : c.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Add tag chip
// ---------------------------------------------------------------------------

class _AddTagChip extends StatelessWidget {
  const _AddTagChip({required this.onAdd});

  final void Function(String text) onAdd;

  Future<void> _showDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.tagAddLabel),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (v) => Navigator.of(ctx).pop(v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.tagAddCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: Text(l10n.tagAddConfirm),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) onAdd(result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final c = context.appColors;

    return GestureDetector(
      onTap: () => _showDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.xxs,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: c.border, width: 0.5),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          l10n.tagAddLabel,
          style: TextStyle(fontSize: 13, color: c.textTertiary),
        ),
      ),
    );
  }
}
