/// Sizes shared by every screen.
abstract final class OnboardingLayout {
  /// The widest the content gets, however wide the space it is given.
  static const double maxWidth = 440;

  /// From this width up the flow stays a centred column of [maxWidth].
  static const double wideBreakpoint = 600;

  /// The smallest comfortable touch target, in logical pixels.
  static const double minTarget = 44;

  /// Horizontal screen padding.
  static const double gutter = 24;
}
