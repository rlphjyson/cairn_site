import '../models/onboarding_flow.dart';
import '../models/onboarding_step.dart';

/// The step before [current], or `null` when it is the first.
class GetPreviousStep {
  /// Creates the use case.
  const GetPreviousStep();

  /// Runs it.
  OnboardingStepKind? call(OnboardingFlow flow, OnboardingStepKind current) {
    final int i = flow.indexOf(current);
    if (i <= 0) return null;
    return flow.steps[i - 1].kind;
  }
}
