import '../models/onboarding_flow.dart';
import '../models/onboarding_step.dart';

/// The step after [current], or `null` when it is the last.
class GetNextStep {
  /// Creates the use case.
  const GetNextStep();

  /// Runs it.
  OnboardingStepKind? call(OnboardingFlow flow, OnboardingStepKind current) {
    final int i = flow.indexOf(current);
    if (i < 0 || i >= flow.steps.length - 1) return null;
    return flow.steps[i + 1].kind;
  }
}
