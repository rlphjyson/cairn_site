import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import 'touch_target.dart';

/// A full-width button for the foot of a step, at least 44 px tall.
class FooterButton extends StatelessWidget {
  /// Creates a button.
  const FooterButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = CairnButtonVariant.primary,
    this.trailing,
    this.leading,
    this.semanticLabel,
  });

  /// The visible label.
  final String label;

  /// Called on tap. `null` disables the button.
  final VoidCallback? onPressed;

  /// The Cairn variant.
  final CairnButtonVariant variant;

  /// An icon after the label.
  final Widget? trailing;

  /// An icon before the label.
  final Widget? leading;

  /// Overrides the accessible name when the visible label is not enough.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => TouchTarget(
    onTap: onPressed,
    child: CairnButton(
      expand: true,
      size: CairnButtonSize.lg,
      variant: variant,
      onPressed: onPressed,
      leading: leading,
      trailing: trailing,
      semanticLabel: semanticLabel,
      child: Text(label),
    ),
  );
}
