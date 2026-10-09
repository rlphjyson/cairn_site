import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import 'touch_target.dart';

/// A stand-alone text link with a 44 px tap area.
class AuthLink extends StatelessWidget {
  /// Creates a link.
  const AuthLink({
    super.key,
    required this.label,
    required this.onPressed,
    this.muted = false,
    this.alignment = Alignment.center,
  });

  /// The link text.
  final String label;

  /// Called when tapped, or `null` to disable.
  final VoidCallback? onPressed;

  /// Whether to use the quieter foreground colour.
  final bool muted;

  /// Horizontal placement inside the available width.
  final Alignment alignment;

  @override
  Widget build(BuildContext context) => TouchTarget(
    onTap: onPressed,
    alignment: alignment,
    child: CairnLink(onPressed: onPressed, muted: muted, child: Text(label)),
  );
}
