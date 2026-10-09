import 'package:flutter/widgets.dart';

/// The smallest comfortable tap size, in logical pixels.
const double minTouchSize = 44;

/// Grows a control's tappable area to at least [minTouchSize] tall.
///
/// Cairn's buttons, links and fields are 36 to 40 px tall. This wraps them in a
/// 44 px region whose empty margin forwards taps to [onTap], so a thumb that
/// lands just above or below still hits. It adds no semantics of its own; the
/// wrapped control keeps announcing itself.
class TouchTarget extends StatelessWidget {
  /// Creates a target.
  const TouchTarget({
    super.key,
    required this.child,
    this.onTap,
    this.alignment = Alignment.center,
  });

  /// The control.
  final Widget child;

  /// Called when the margin is tapped. `null` makes the margin inert.
  final VoidCallback? onTap;

  /// Where the control sits horizontally when it is narrower than its space.
  final Alignment alignment;

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    excludeFromSemantics: true,
    onTap: onTap,
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: minTouchSize),
      child: Align(alignment: alignment, widthFactor: 1, child: child),
    ),
  );
}
