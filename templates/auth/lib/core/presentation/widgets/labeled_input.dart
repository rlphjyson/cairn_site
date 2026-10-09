import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../auth_text.dart';
import 'touch_target.dart';

/// A labelled text field with an inline error and a 44 px tap area.
///
/// Every form field in the template is one of these, so labels, spacing and
/// error styling stay identical across screens. The error is announced as a
/// live region when it appears and is part of the field's accessible name, so
/// a screen reader reads it with the field.
class LabeledInput extends StatefulWidget {
  /// Creates a field.
  const LabeledInput({
    super.key,
    required this.label,
    required this.controller,
    this.onChanged,
    this.onFocusLost,
    this.onSubmitted,
    this.error,
    this.placeholder,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.inputFormatters,
    this.obscureText = false,
    this.autofocus = false,
    this.enabled = true,
    this.action,
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

  /// Hint text.
  final String? placeholder;

  /// The keyboard to show.
  final TextInputType? keyboardType;

  /// What the keyboard's action key does.
  final TextInputAction textInputAction;

  /// Restricts or reshapes the input.
  final List<TextInputFormatter>? inputFormatters;

  /// Whether to hide the text.
  final bool obscureText;

  /// Whether to focus on build.
  final bool autofocus;

  /// Whether the field accepts input.
  final bool enabled;

  /// A control laid over the field's trailing edge (the show/hide button).
  /// It is given a 44 by 44 area.
  final Widget? action;

  @override
  State<LabeledInput> createState() => _LabeledInputState();
}

class _LabeledInputState extends State<LabeledInput> {
  final FocusNode _focus = FocusNode();
  bool _hadFocus = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocus);
  }

  void _onFocus() {
    if (_hadFocus && !_focus.hasFocus) {
      widget.onFocusLost?.call(widget.controller.text);
    }
    _hadFocus = _focus.hasFocus;
  }

  @override
  void dispose() {
    _focus
      ..removeListener(_onFocus)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final String? error = widget.error;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ExcludeSemantics(
          child: Text(
            widget.label,
            style: authText(
              theme,
              CairnTypography.sm,
              weight: CairnTypography.medium,
            ),
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          onTap: widget.enabled ? _focus.requestFocus : null,
          child: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: CairnInput(
                  controller: widget.controller,
                  focusNode: _focus,
                  placeholder: widget.placeholder,
                  semanticLabel: error == null
                      ? widget.label
                      : '${widget.label}. $error',
                  hasError: error != null,
                  enabled: widget.enabled,
                  keyboardType: widget.keyboardType,
                  textInputAction: widget.textInputAction,
                  inputFormatters: widget.inputFormatters,
                  obscureText: widget.obscureText,
                  autofocus: widget.autofocus,
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                  // Keeps typed text clear of the overlaid action.
                  trailing: widget.action == null
                      ? null
                      : const SizedBox(width: 28),
                ),
              ),
              if (widget.action != null)
                PositionedDirectional(
                  top: 0,
                  end: 0,
                  bottom: 0,
                  width: minTouchSize,
                  child: widget.action!,
                ),
            ],
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Semantics(
              liveRegion: true,
              container: true,
              child: Text(
                error,
                style: authText(
                  theme,
                  CairnTypography.xs,
                  color: theme.destructive,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
