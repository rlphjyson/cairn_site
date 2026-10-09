import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import 'touch_target.dart';

/// A full-width button with a loading state.
///
/// While [loading] the button shows Cairn's spinner and [loadingLabel] and
/// ignores presses, but keeps its normal look instead of dimming like a
/// disabled one. Pass `onPressed: null` for a genuinely disabled button (a
/// lockout, say).
class AuthButton extends StatelessWidget {
  /// Creates a button.
  const AuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.loadingLabel,
    this.variant = CairnButtonVariant.primary,
    this.leading,
  });

  /// The button's text.
  final String label;

  /// Called on press, or `null` to disable.
  final VoidCallback? onPressed;

  /// Whether a request is in flight.
  final bool loading;

  /// The text while [loading]; falls back to [label].
  final String? loadingLabel;

  /// The Cairn button variant.
  final CairnButtonVariant variant;

  /// A glyph before the label.
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final String text = loading ? (loadingLabel ?? label) : label;
    final VoidCallback? handler = loading ? () {} : onPressed;
    final Color spinnerColor = variant == CairnButtonVariant.primary
        ? theme.primaryForeground
        : theme.foreground;
    return TouchTarget(
      onTap: handler,
      child: CairnButton(
        size: CairnButtonSize.lg,
        expand: true,
        variant: variant,
        onPressed: handler,
        semanticLabel: text,
        leading: loading
            ? CairnSpinner(
                size: 16,
                color: spinnerColor,
                semanticLabel: loadingLabel ?? label,
              )
            : leading,
        child: Text(text),
      ),
    );
  }
}
