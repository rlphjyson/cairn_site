import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/widgets.dart';

import '../layout.dart';

/// The outer frame of a page section: vertical rhythm, a centred column no
/// wider than [LandingLayout.maxContentWidth], and an optional tinted band.
class SectionFrame extends StatelessWidget {
  /// Creates a frame.
  const SectionFrame({
    super.key,
    required this.child,
    this.tinted = false,
    this.verticalPadding,
  });

  /// The section's content.
  final Widget child;

  /// Whether the band has a subtle muted background and hairlines.
  final bool tinted;

  /// Overrides the default top and bottom padding.
  final double? verticalPadding;

  /// The side gutter at [breakpoint].
  static double gutterFor(LandingBreakpoint breakpoint) =>
      breakpoint == LandingBreakpoint.compact
      ? CairnSpacing.s5
      : CairnSpacing.s8;

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    final LandingViewport viewport = LandingViewport.of(context);
    final double vertical =
        verticalPadding ??
        switch (viewport.breakpoint) {
          LandingBreakpoint.compact => 56.0,
          LandingBreakpoint.medium => 80.0,
          LandingBreakpoint.expanded => 96.0,
        };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tinted ? theme.muted.withValues(alpha: 0.45) : null,
        border: tinted
            ? Border.symmetric(horizontal: BorderSide(color: theme.border))
            : null,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: LandingLayout.maxContentWidth,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: gutterFor(viewport.breakpoint),
              vertical: vertical,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
