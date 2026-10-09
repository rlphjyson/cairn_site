import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';

/// An icon button with a 44 by 44 touch target (Cairn's largest icon button is
/// 40), and an accessible name.
class IconAction extends StatelessWidget {
  /// Creates an icon action.
  IconAction({
    super.key,
    required IconData icon,
    required this.label,
    required this.onPressed,
    this.variant = CairnButtonVariant.ghost,
    this.size = CairnButtonSize.iconLg,
  }) : glyph = Icon(icon);

  /// Creates an action whose face is any widget, such as an emoji.
  const IconAction.glyph({
    super.key,
    required this.glyph,
    required this.label,
    required this.onPressed,
    this.variant = CairnButtonVariant.ghost,
    this.size = CairnButtonSize.iconLg,
  });

  /// What the button shows.
  final Widget glyph;

  /// The accessible name.
  final String label;

  /// Called on tap; `null` disables the button.
  final VoidCallback? onPressed;

  /// Ghost by default; use primary for the send button.
  final CairnButtonVariant variant;

  /// The visible button size inside the 44 pixel target.
  final CairnButtonSize size;

  @override
  Widget build(BuildContext context) => GestureDetector(
    // The button inside carries the semantics; this only widens the target.
    excludeFromSemantics: true,
    behavior: HitTestBehavior.opaque,
    onTap: onPressed,
    child: SizedBox.square(
      dimension: 44,
      child: Center(
        child: CairnButton.icon(
          icon: glyph,
          semanticLabel: label,
          onPressed: onPressed,
          variant: variant,
          size: size,
        ),
      ),
    ),
  );
}
