import '../../domain/flow/models/onboarding_step.dart';
import '../../domain/progress/models/onboarding_result.dart';

/// The host's callbacks, shared with the cubits.
///
/// `OnboardingApp` owns one and keeps its fields current when the widget is
/// rebuilt with new callbacks, so a host never has to re-create the app to
/// change what it does when onboarding ends.
class OnboardingHooks {
  /// Creates hooks.
  OnboardingHooks({this.onCompleted, this.onSkipped, this.onStepChanged});

  /// Called once when the user presses Start.
  void Function(OnboardingResult result)? onCompleted;

  /// Called when the user skips a step that allows it, with the step skipped.
  void Function(OnboardingStepKind step)? onSkipped;

  /// Called whenever a step is shown, including the first. Useful for
  /// analytics.
  void Function(OnboardingStepKind step)? onStepChanged;
}
