import 'package:flutter/widgets.dart';

/// A tappable region with a pointer cursor and button semantics.
class TapTarget extends StatelessWidget {
  /// Creates a target.
  const TapTarget({
    super.key,
    required this.onTap,
    required this.child,
    this.semanticLabel,
  });

  /// Called on tap.
  final VoidCallback onTap;

  /// The tappable content.
  final Widget child;

  /// Announced to assistive technology.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: semanticLabel,
    child: MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: child,
      ),
    ),
  );
}
