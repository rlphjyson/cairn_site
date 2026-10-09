import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import 'touch_target.dart';

/// A checkbox with a label, laid out in a 44 px tall row that toggles when
/// tapped anywhere.
class CheckRow extends StatelessWidget {
  /// Creates a row.
  const CheckRow({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    required this.semanticLabel,
    this.hasError = false,
  });

  /// Whether the box is checked.
  final bool value;

  /// Called with the new value.
  final ValueChanged<bool> onChanged;

  /// The visible label. May contain links.
  final Widget label;

  /// What a screen reader says for the checkbox.
  final String semanticLabel;

  /// Whether to draw the box in its error colour.
  final bool hasError;

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    excludeFromSemantics: true,
    onTap: () => onChanged(!value),
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: minTouchSize),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: CairnCheckbox(
              value: value,
              hasError: hasError,
              semanticLabel: semanticLabel,
              onChanged: (bool? v) => onChanged(v ?? false),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 24),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  widthFactor: 1,
                  child: label,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
