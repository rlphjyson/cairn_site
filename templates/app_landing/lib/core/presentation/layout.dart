import 'package:flutter/widgets.dart';

/// How much room the page has.
enum AppLandingBreakpoint {
  /// A phone: under 640 logical pixels.
  compact,

  /// A tablet or a narrow window: 640 to 1023.
  medium,

  /// A desktop: 1024 and up.
  expanded,
}

/// Layout constants shared by every section.
abstract final class AppLandingLayout {
  /// The widest the content gets; wider screens get margins.
  static const double maxContentWidth = 1120;

  /// The widest copy column (subtitles, paragraphs).
  static const double maxCopyWidth = 640;

  /// The viewport width below which the navbar collapses into a menu.
  static const double navCollapseWidth = 1000;

  /// The navbar height.
  static const double navHeight = 64;

  /// The breakpoint for a viewport [width].
  static AppLandingBreakpoint breakpointFor(double width) {
    if (width < 640) return AppLandingBreakpoint.compact;
    if (width < 1024) return AppLandingBreakpoint.medium;
    return AppLandingBreakpoint.expanded;
  }
}

/// The width the page is laid out in, and the breakpoint it falls in.
///
/// Measured from the space the template is given rather than from the screen,
/// so it behaves when embedded in a narrower frame.
class AppLandingViewport extends InheritedWidget {
  /// Creates a viewport.
  const AppLandingViewport({
    super.key,
    required this.width,
    required super.child,
  });

  /// The width available to the page.
  final double width;

  /// The breakpoint for [width].
  AppLandingBreakpoint get breakpoint => AppLandingLayout.breakpointFor(width);

  /// Whether this is a phone-width layout.
  bool get isCompact => breakpoint == AppLandingBreakpoint.compact;

  /// Whether this is a desktop-width layout.
  bool get isExpanded => breakpoint == AppLandingBreakpoint.expanded;

  /// Whether the navbar shows a menu button instead of links.
  bool get collapsesNav => width < AppLandingLayout.navCollapseWidth;

  /// The nearest viewport.
  static AppLandingViewport of(BuildContext context) {
    final AppLandingViewport? v = context
        .dependOnInheritedWidgetOfExactType<AppLandingViewport>();
    assert(v != null, 'No AppLandingViewport above this context.');
    return v!;
  }

  @override
  bool updateShouldNotify(AppLandingViewport oldWidget) =>
      width != oldWidget.width;
}
