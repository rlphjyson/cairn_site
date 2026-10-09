import 'package:flutter/widgets.dart';

import '../../../common/constants/settings_layout.dart';

/// Grows the tappable area of [child] to at least 44 by 44 logical pixels.
///
/// Cairn's buttons are 32 to 40 px tall, below the comfortable minimum for a
/// thumb. The Cairn control keeps its own look, focus ring and semantics; this
/// wrapper only adds an invisible margin that calls [onTap] as well. It adds no
/// semantics of its own, so screen readers still meet one control, not two.
class TouchTarget extends StatelessWidget {
  /// Creates a target.
  const TouchTarget({super.key, required this.onTap, required this.child});

  /// Called when the extra margin is tapped; pass the same callback as the
  /// control inside. `null` disables the margin.
  final VoidCallback? onTap;

  /// The Cairn control.
  final Widget child;

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    excludeFromSemantics: true,
    onTap: onTap,
    child: ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: SettingsLayout.minTarget,
        minHeight: SettingsLayout.minTarget,
      ),
      child: Center(widthFactor: 1, heightFactor: 1, child: child),
    ),
  );
}
