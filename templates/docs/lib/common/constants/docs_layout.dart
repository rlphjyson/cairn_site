/// Breakpoints and measures shared by the shell and the page.
abstract final class DocsLayout {
  /// Below this width the sidebar becomes a drawer opened from a menu button.
  static const double drawerBreakpoint = 900;

  /// Below this width the "On this page" rail is hidden.
  static const double tocBreakpoint = 1100;

  /// Below this width previous / next links stack.
  static const double pagerBreakpoint = 560;

  /// The top bar height.
  static const double topBarHeight = 56;

  /// The sidebar width.
  static const double sidebarWidth = 272;

  /// The "On this page" rail width.
  static const double tocWidth = 216;

  /// The reading measure: the widest the article text ever gets.
  static const double contentMaxWidth = 720;
}
