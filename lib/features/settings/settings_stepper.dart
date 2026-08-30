import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../theme/typography.dart';

/// Compact minus/value/plus stepper row used across Settings numeric
/// inputs. Renders as a single row — label on the left, the control group
/// on the right — instead of a full-width row of controls with the label
/// stacked above it.
class SettingsStepper extends StatelessWidget {
  const SettingsStepper({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.format,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final int step;
  final String Function(int value) format;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.labelLarge),
        ),
        IconButton.filledTonal(
          onPressed: value > min ? () => onChanged(value - step) : null,
          icon: const Icon(Icons.remove),
        ),
        SizedBox(
          width: 44,
          child: Text(
            format(value),
            textAlign: TextAlign.center,
            style: BreathLabTypography.numericMd.copyWith(
              color: context.appColors.textPrimary,
            ),
          ),
        ),
        IconButton.filledTonal(
          onPressed: value < max ? () => onChanged(value + step) : null,
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}
