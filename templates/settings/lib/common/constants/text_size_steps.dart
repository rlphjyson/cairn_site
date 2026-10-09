/// The four text sizes the Appearance screen offers.
///
/// The slider stores the step index (0 to 3); the app multiplies the system
/// text scale by the matching factor.
abstract final class TextSizeSteps {
  /// What each step is called.
  static const List<String> labels = <String>[
    'Small',
    'Default',
    'Large',
    'Extra large',
  ];

  /// How much each step scales text, on top of the system setting.
  static const List<double> factors = <double>[0.9, 1.0, 1.15, 1.3];

  /// The step that leaves text as the system has it.
  static const int defaultStep = 1;

  /// The factor for [step], clamped to the valid range.
  static double factorOf(int step) =>
      factors[step.clamp(0, factors.length - 1)];
}
