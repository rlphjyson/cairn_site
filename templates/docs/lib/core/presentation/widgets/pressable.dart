import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

/// A keyboard-focusable, hoverable button surface for rows that Cairn's own
/// buttons do not fit (sidebar items, table-of-contents entries, pager cards).
///
/// It activates on tap, Enter and Space, announces itself as a button, shows
/// the Cairn focus ring only for keyboard focus, and hands the builder the
/// hover and focus state so the row can restyle itself.
class Pressable extends StatefulWidget {
  /// Creates a pressable surface.
  const Pressable({
    super.key,
    required this.onTap,
    required this.builder,
    this.semanticLabel,
    this.selected = false,
    this.borderRadius,
  });

  /// Called on activation.
  final VoidCallback onTap;

  /// Builds the content from the current hover and focus state.
  final Widget Function(BuildContext context, bool hovered, bool focused)
  builder;

  /// Announced instead of the visible text, when set.
  final String? semanticLabel;

  /// Whether this is the current item (announced as selected).
  final bool selected;

  /// The radius of the focus ring; defaults to the theme's `md`.
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
    return Semantics(
      button: true,
      selected: widget.selected,
      label: widget.semanticLabel,
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        onShowHoverHighlight: (bool v) => setState(() => _hovered = v),
        onShowFocusHighlight: (bool v) => setState(() => _focused = v),
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onTap();
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
            child: widget.builder(context, _hovered, _focused),
          ),
        ),
      ),
    );
  }
}
