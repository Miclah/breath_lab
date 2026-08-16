import 'package:flutter/material.dart';

import '../../theme/colors.dart';
import '../../theme/typography.dart';

/// Slider for a persisted setting.
///
/// The thumb follows the finger from local state and only persists on
/// release, via [onCommit]. Driving [Slider.value] straight from the stored
/// setting made the thumb wait for a database write on every drag frame,
/// which on Android (where drift runs in a background isolate) meant it
/// could not keep up with the finger at all.
class SettingsSlider extends StatefulWidget {
  const SettingsSlider({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.labelBuilder,
    required this.onCommit,
    this.enabled = true,
  });

  final String label;

  /// The persisted value, shown whenever a drag isn't in progress.
  final int value;
  final int min;
  final int max;
  final int divisions;

  /// Builds the value-indicator label for the currently displayed value.
  final String Function(int value) labelBuilder;

  /// Called once, with the final value, when the drag ends.
  final ValueChanged<int> onCommit;

  final bool enabled;

  @override
  State<SettingsSlider> createState() => _SettingsSliderState();
}

class _SettingsSliderState extends State<SettingsSlider> {
  /// Non-null only while dragging.
  int? _dragValue;

  @override
  Widget build(BuildContext context) {
    final displayed = _dragValue ?? widget.value;
    final c = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.label,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            Text(
              widget.labelBuilder(displayed),
              style: BreathLabTypography.statMd.copyWith(color: c.textPrimary),
            ),
          ],
        ),
        Slider(
          value: displayed.toDouble().clamp(
            widget.min.toDouble(),
            widget.max.toDouble(),
          ),
          min: widget.min.toDouble(),
          max: widget.max.toDouble(),
          divisions: widget.divisions,
          label: widget.labelBuilder(displayed),
          onChanged: !widget.enabled
              ? null
              : (v) => setState(() => _dragValue = v.round()),
          onChangeEnd: !widget.enabled
              ? null
              : (v) {
                  setState(() => _dragValue = null);
                  widget.onCommit(v.round());
                },
        ),
      ],
    );
  }
}
