import 'package:flutter/material.dart' hide Durations;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/widgets/adaptive_page.dart';
import '../../theme/colors.dart';
import '../../theme/surfaces.dart';
import '../../theme/tokens.dart';
import '../../theme/typography.dart';
import 'providers.dart';
import 'report_block_view.dart';
import 'report_markdown.dart';

/// The in-app research reader. Renders the bundled markdown through the app's
/// own type tokens with a section index — no webview, no network.
///
/// `RESEARCH_ALIGNMENT.md` §5: the report is English-only for now, and the
/// reader says so rather than presenting English silently inside a Slovak UI.
class ReportReaderScreen extends ConsumerStatefulWidget {
  const ReportReaderScreen({super.key});

  @override
  ConsumerState<ReportReaderScreen> createState() => _ReportReaderScreenState();
}

class _ReportReaderScreenState extends ConsumerState<ReportReaderScreen> {
  /// One key per anchored heading, used both by the section index and by the
  /// deep-link jump.
  final _anchorKeys = <String, GlobalKey>{};

  GlobalKey _keyFor(String anchor) =>
      _anchorKeys.putIfAbsent(anchor, GlobalKey.new);

  void _jumpTo(String anchor) {
    final target = _anchorKeys[anchor]?.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      duration: Durations.slow,
      curve: Curves.easeOut,
      alignment: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final blocks = ref.watch(reportBlocksProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reportReaderTitle)),
      body: SafeArea(
        child: blocks.when(
          loading: () => const SizedBox.shrink(),
          error: (_, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(Spacing.xl),
              child: Text(
                l10n.reportReaderLoadFailed,
                style: BreathLabTypography.body,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          data: (blocks) =>
              _Reader(blocks: blocks, keyFor: _keyFor, onJump: _jumpTo),
        ),
      ),
    );
  }
}

class _Reader extends StatelessWidget {
  const _Reader({
    required this.blocks,
    required this.keyFor,
    required this.onJump,
  });

  final List<ReportBlock> blocks;
  final GlobalKey Function(String) keyFor;
  final void Function(String) onJump;

  List<_Entry> get _index => [
    for (final block in blocks)
      if (block is HeadingBlock && block.level >= 2 && block.anchor != null)
        _Entry(block.anchor!, block.plainText, block.level),
  ];

  Widget _body(BuildContext context, {required bool withInlineIndex}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _LanguageNotice(),
          if (withInlineIndex)
            Padding(
              padding: const EdgeInsets.only(top: Spacing.lg),
              child: _JumpList(
                entries: _index,
                onJump: onJump,
                collapsible: true,
              ),
            ),
          for (final block in blocks)
            if (block is HeadingBlock && block.anchor != null)
              KeyedSubtree(
                key: keyFor(block.anchor!),
                child: ReportBlockView(block),
              )
            else
              ReportBlockView(block),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final showsSide = AdaptivePage.showsSide(
          constraints.maxWidth,
          maxWidth: ContentWidth.reading,
        );
        return AdaptivePage(
          maxWidth: ContentWidth.reading,
          side: showsSide
              ? _JumpList(entries: _index, onJump: onJump, collapsible: false)
              : null,
          child: _body(context, withInlineIndex: !showsSide),
        );
      },
    );
  }
}

class _Entry {
  const _Entry(this.anchor, this.title, this.level);
  final String anchor;
  final String title;
  final int level;
}

class _JumpList extends StatelessWidget {
  const _JumpList({
    required this.entries,
    required this.onJump,
    required this.collapsible,
  });

  final List<_Entry> entries;
  final void Function(String) onJump;

  /// Compact lays the index above the text, where it earns its space only if
  /// it can be folded away; the side slot shows it open.
  final bool collapsible;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final l10n = AppLocalizations.of(context)!;

    final list = Container(
      decoration: Surfaces.inset(context),
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final entry in entries)
            InkWell(
              onTap: () => onJump(entry.anchor),
              child: Padding(
                padding: EdgeInsets.only(
                  left: entry.level >= 3 ? Spacing.xl : Spacing.md,
                  right: Spacing.md,
                  top: Spacing.sm,
                  bottom: Spacing.sm,
                ),
                child: Text(
                  entry.title,
                  style: BreathLabTypography.body.copyWith(
                    color: entry.level >= 3 ? c.textTertiary : c.textSecondary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    final heading = Padding(
      padding: const EdgeInsets.only(left: Spacing.md, bottom: Spacing.sm),
      child: Text(
        l10n.reportReaderJumpTo.toUpperCase(),
        style: BreathLabTypography.section.copyWith(color: c.textTertiary),
      ),
    );

    if (!collapsible) {
      return ListView(
        padding: const EdgeInsets.symmetric(vertical: Spacing.xl),
        children: [heading, list],
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(top: Spacing.sm),
        title: Text(
          l10n.reportReaderJumpTo.toUpperCase(),
          style: BreathLabTypography.section.copyWith(color: c.textTertiary),
        ),
        children: [list],
      ),
    );
  }
}

class _LanguageNotice extends StatelessWidget {
  const _LanguageNotice();

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Text(
      AppLocalizations.of(context)!.reportReaderLanguageNotice,
      style: BreathLabTypography.micro.copyWith(color: c.textTertiary),
    );
  }
}
