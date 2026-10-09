import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../settings_text.dart';
import 'control_scale.dart';

/// A [CairnFormField] whose label wraps.
///
/// Cairn's own label never breaks onto a second line, so a long label such as
/// "Confirm new password" overflows at large text sizes. This draws the label
/// itself (in the same style) and leaves the description and the error, which
/// do wrap, to [CairnFormField].
class LabeledField extends StatelessWidget {
  /// Creates a field.
  const LabeledField({
    super.key,
    required this.label,
    required this.child,
    this.error,
    this.description,
  });

  /// The label above the control.
  final String label;

  /// The control.
  final Widget child;

  /// The error under the control. Turns the label red.
  final String? error;

  /// Help under the control, replaced by [error] when there is one.
  final String? description;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          label,
          style: settingsText(
            theme,
            CairnTypography.sm,
            color: error == null ? theme.foreground : theme.destructive,
            weight: CairnTypography.medium,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        CairnFormField(
          error: error,
          description: description,
          child: ControlScale(child: child),
        ),
      ],
    );
  }
}
