import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';

import '../auth_copy.dart';
import 'labeled_input.dart';

/// A password [LabeledInput] with a show/hide toggle.
///
/// The toggle is a 44 px button laid over the field's trailing edge, with a
/// spoken label that says what it will do. A revealed password is
/// hidden again when the screen is left.
class PasswordField extends StatefulWidget {
  /// Creates a field.
  const PasswordField({
    super.key,
    required this.label,
    required this.controller,
    this.onChanged,
    this.onFocusLost,
    this.onSubmitted,
    this.error,
    this.textInputAction = TextInputAction.next,
    this.autofocus = false,
    this.enabled = true,
  });

  /// The label above the field.
  final String label;

  /// Holds the text.
  final TextEditingController controller;

  /// Called on every edit.
  final ValueChanged<String>? onChanged;

  /// Called with the text when the field loses focus.
  final ValueChanged<String>? onFocusLost;

  /// Called when the keyboard's action key is pressed.
  final ValueChanged<String>? onSubmitted;

  /// The message to show, or `null` when the field is fine.
  final String? error;

  /// What the keyboard's action key does.
  final TextInputAction textInputAction;

  /// Whether to focus on build.
  final bool autofocus;

  /// Whether the field accepts input.
  final bool enabled;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return LabeledInput(
      label: widget.label,
      controller: widget.controller,
      onChanged: widget.onChanged,
      onFocusLost: widget.onFocusLost,
      onSubmitted: widget.onSubmitted,
      error: widget.error,
      textInputAction: widget.textInputAction,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      obscureText: !_visible,
      keyboardType: TextInputType.visiblePassword,
      action: Semantics(
        button: true,
        label: _visible ? AuthCopy.hidePassword : AuthCopy.showPassword,
        excludeSemantics: true,
        onTap: () => setState(() => _visible = !_visible),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _visible = !_visible),
          child: Center(
            child: Icon(
              _visible
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 18,
              color: theme.mutedForeground,
            ),
          ),
        ),
      ),
    );
  }
}
