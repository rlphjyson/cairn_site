import 'package:flutter/widgets.dart';

/// Motion that respects the user's "reduce motion" setting.
///
/// Every animation in the template takes its duration from here, so turning
/// reduced motion on (`MediaQuery.disableAnimations`) makes every transition
/// instant. Durations themselves come from `CairnMotion`.
abstract final class OnboardingMotion {
  /// Whether the user asked for no animation.
  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// [duration], or zero when motion is reduced.
  static Duration of(BuildContext context, Duration duration) =>
      reduced(context) ? Duration.zero : duration;
}
