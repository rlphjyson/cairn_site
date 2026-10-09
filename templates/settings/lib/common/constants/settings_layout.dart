/// Sizes shared by every screen.
abstract final class SettingsLayout {
  /// From this width up the settings become two panes: the categories on the
  /// left, the selected category on the right.
  static const double wideBreakpoint = 600;

  /// The width of the categories pane in two-pane mode.
  static const double listPaneWidth = 288;

  /// The widest a category's content gets.
  static const double maxContentWidth = 560;

  /// The smallest comfortable touch target, in logical pixels.
  static const double minTarget = 44;

  /// Horizontal screen padding.
  static const double gutter = 16;
}
