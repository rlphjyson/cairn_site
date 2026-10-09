import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../dashboard_text.dart';

/// A coloured swatch, a label and an optional value, for chart legends.
class LegendRow extends StatelessWidget {
  /// Creates a row.
  const LegendRow({
    super.key,
    required this.color,
    required this.label,
    this.value,
    this.labelWidth = 76,
  });

  /// The series colour.
  final Color color;

  /// The series name.
  final String label;

  /// A figure shown after the label.
  final String? value;

  /// Fixed label width, so values line up in a column.
  final double labelWidth;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(theme.radiusScale.sm / 2),
          ),
        ),
        const SizedBox(width: CairnSpacing.s2p5),
        SizedBox(
          width: value == null ? null : labelWidth,
          child: Text(
            label,
            style: dashText(
              theme,
              theme.textStyle(CairnTypography.sm),
              color: theme.mutedForeground,
            ),
          ),
        ),
        if (value != null)
          Text(
            value!,
            style: dashText(
              theme,
              theme.textStyle(CairnTypography.sm),
              weight: CairnTypography.medium,
            ),
          ),
      ],
    );
  }
}
