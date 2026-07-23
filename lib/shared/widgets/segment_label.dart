import 'package:flutter/material.dart';

/// Label for a [ButtonSegment], shrunk to fit on one line instead of
/// wrapping — [SegmentedButton] gives each segment equal width regardless
/// of label length, so a long label can otherwise force an ugly mid-word
/// wrap (e.g. "Milestones" splitting into "Milesto" / "nes").
class SegmentLabel extends StatelessWidget {
  const SegmentLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(text, maxLines: 1, softWrap: false),
    );
  }
}
