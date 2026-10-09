import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../shop_text.dart';

/// A text field with a label above it and an inline error below.
///
/// Every checkout field is one of these, so labels, spacing and error styling
/// stay identical across the forms.
class LabeledField extends StatelessWidget {
  /// Creates a field.
  const LabeledField({
    super.key,
    required this.label,
    required this.controller,
    required this.onChanged,
    this.error,
    this.placeholder,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.inputFormatters,
    this.maxLength,
    this.obscureText = false,
    this.autofocus = false,
  });

  /// The label.
  final String label;

  /// Holds the text.
  final TextEditingController controller;

  /// Called on every edit.
  final ValueChanged<String> onChanged;

  /// The message to show, or `null` when the field is fine.
  final String? error;

  /// Hint text.
  final String? placeholder;

  /// The keyboard to show.
  final TextInputType? keyboardType;

  /// What the keyboard's action key does.
  final TextInputAction textInputAction;

  /// Restricts or reshapes the input.
  final List<TextInputFormatter>? inputFormatters;

  /// The most characters allowed.
  final int? maxLength;

  /// Whether to hide the text.
  final bool obscureText;

  /// Whether to focus on build.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: shopText(
            theme,
            theme.textStyle(CairnTypography.sm),
            weight: CairnTypography.medium,
          ),
        ),
        const SizedBox(height: 6),
        CairnInput(
          controller: controller,
          placeholder: placeholder,
          semanticLabel: label,
          hasError: error != null,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          obscureText: obscureText,
          autofocus: autofocus,
          onChanged: onChanged,
        ),
        if (error != null) ...<Widget>[
          const SizedBox(height: 4),
          Semantics(
            liveRegion: true,
            child: Text(
              error!,
              style: shopText(
                theme,
                theme.textStyle(CairnTypography.xs),
                color: theme.destructive,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
