import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

/// What a [Pressable] is currently doing.
class PressState {
  /// Creates a state.
  const PressState({required this.hovered, required this.focused});

  /// The pointer is over it.
  final bool hovered;

  /// It has keyboard focus and the focus highlight is showing.
  final bool focused;
}

/// A tappable surface with a pointer cursor, hover and keyboard focus.
///
/// Cairn's own buttons cover most controls; this is for the larger clickable
/// regions (cards, the brand, tags) that are not buttons. It is a tab stop,
/// activates on Enter and Space, and draws Cairn's focus ring when focused
/// from the keyboard.
class Pressable extends StatefulWidget {
  /// Creates a pressable.
  const Pressable({
    super.key,
    required this.builder,
    required this.onTap,
    required this.semanticLabel,
    this.borderRadius,
  });

  /// Builds the content from the current [PressState].
  final Widget Function(BuildContext context, PressState state) builder;

  /// Called on tap, Enter or Space.
  final VoidCallback? onTap;

  /// What a screen reader announces.
  final String semanticLabel;

  /// Rounds the focus ring; defaults to the theme's `md`.
  final BorderRadius? borderRadius;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final bool enabled = widget.onTap != null;

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.semanticLabel,
      excludeSemantics: true,
      onTap: widget.onTap,
      child: FocusableActionDetector(
        enabled: enabled,
        mouseCursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
        onShowHoverHighlight: (bool v) => setState(() => _hovered = v),
        onShowFocusHighlight: (bool v) => setState(() => _focused = v),
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (ActivateIntent _) {
              widget.onTap?.call();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius:
                  widget.borderRadius ??
                  BorderRadius.circular(theme.radiusScale.md),
              boxShadow: _focused ? theme.focusRing : null,
            ),
            child: widget.builder(
              context,
              PressState(hovered: _hovered, focused: _focused),
            ),
          ),
        ),
      ),
    );
  }
}
