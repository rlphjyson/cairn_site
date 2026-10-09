import 'package:flutter/widgets.dart';

/// A tappable, focusable area with the semantics of a radio option or button.
///
/// Cairn's own interactive base is internal, so the few custom controls the
/// template draws (avatar and accent swatches) use this. It handles keyboard
/// activation, exposes whether it has focus to [builder] so the control can draw
/// a ring, and describes itself to assistive technology.
class FocusTap extends StatefulWidget {
  /// Creates a tappable area.
  const FocusTap({
    super.key,
    required this.onTap,
    required this.builder,
    required this.label,
    this.selected,
  });

  /// Called on tap, Enter and Space. `null` disables it.
  final VoidCallback? onTap;

  /// Builds the visual, told whether the area has keyboard focus.
  final Widget Function(BuildContext context, bool focused) builder;

  /// The accessible name.
  final String label;

  /// For a radio-like option, whether it is the chosen one. `null` makes it a
  /// plain button.
  final bool? selected;

  @override
  State<FocusTap> createState() => _FocusTapState();
}

class _FocusTapState extends State<FocusTap> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.onTap != null;
    final bool radio = widget.selected != null;
    return Semantics(
      label: widget.label,
      button: !radio,
      inMutuallyExclusiveGroup: radio,
      checked: radio ? widget.selected : null,
      enabled: enabled,
      onTap: widget.onTap,
      excludeSemantics: true,
      child: FocusableActionDetector(
        enabled: enabled,
        mouseCursor: enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onShowFocusHighlight: (bool v) => setState(() => _focused = v),
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onTap?.call();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: widget.builder(context, _focused),
        ),
      ),
    );
  }
}
