import '../../personalise/use_cases/validate_interests.dart';
import '../../progress/models/onboarding_progress.dart';
import '../models/onboarding_flow.dart';
import '../models/onboarding_step.dart';

/// The progress rules: whether the user has done what [step] needs before the
/// flow may move on.
///
/// Only personalise has requirements: enough interests, a goal and a reminder
/// choice. Every other step can be left at any time. Skipping never bypasses
/// these rules, because personalise is not skippable.
class CanAdvance {
  /// Creates the use case.
  const CanAdvance([this._validateInterests = const ValidateInterests()]);

  final ValidateInterests _validateInterests;

  /// Runs it.
  bool call(
    OnboardingFlow flow,
    OnboardingProgress progress,
    OnboardingStepKind step,
  ) {
    if (step != OnboardingStepKind.personalise) return true;
    final bool interests = _validateInterests(
      selected: progress.interests,
      available: flow.interests,
      min: flow.minInterests,
    ).isValid;
    final bool goal = flow.goals.isEmpty || flow.goal(progress.goalId) != null;
    final bool reminder =
        flow.reminders.isEmpty || flow.reminder(progress.reminderId) != null;
    return interests && goal && reminder;
  }
}
