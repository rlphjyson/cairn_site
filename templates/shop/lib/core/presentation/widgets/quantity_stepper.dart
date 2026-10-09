import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../shop_text.dart';

/// A minus button, the quantity and a plus button.
///
/// The buttons are 36px square, close to the 44px touch target, and carry
/// semantic labels built from [subject].
class QuantityStepper extends StatelessWidget {
  /// Creates a stepper.
  const QuantityStepper({
    super.key,
    required this.value,
    required this.onChanged,
    required this.subject,
    this.min = 1,
    this.max = 10,
  });

  /// The current quantity.
  final int value;

  /// Called with the requested quantity.
  final ValueChanged<int> onChanged;

  /// What is being counted, for screen readers, e.g. `Court Low Sneaker`.
  final String subject;

  /// The smallest allowed quantity. Pass 0 to let the minus button remove.
  final int min;

  /// The largest allowed quantity.
  final int max;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        CairnButton.icon(
          variant: CairnButtonVariant.outline,
          icon: const CairnIcon(CairnIconData.minus, size: 14),
          semanticLabel: value <= min && min == 0
              ? 'Remove $subject'
              : 'Decrease quantity of $subject',
          onPressed: value > min ? () => onChanged(value - 1) : null,
        ),
        Semantics(
          label: 'Quantity of $subject',
          value: '$value',
          child: SizedBox(
            width: 32,
            child: ExcludeSemantics(
              child: Text(
                '$value',
                textAlign: TextAlign.center,
                style: shopText(
                  theme,
                  theme.textStyle(CairnTypography.sm),
                  weight: CairnTypography.medium,
                ),
              ),
            ),
          ),
        ),
        CairnButton.icon(
          variant: CairnButtonVariant.outline,
          icon: const CairnIcon(CairnIconData.plus, size: 14),
          semanticLabel: 'Increase quantity of $subject',
          onPressed: value < max ? () => onChanged(value + 1) : null,
        ),
      ],
    );
  }
}
