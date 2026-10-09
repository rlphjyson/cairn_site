import '../../flow/models/onboarding_flow.dart';
import '../../flow/models/onboarding_step.dart';
import '../../flow/use_cases/can_advance.dart';
import '../../personalise/models/interest.dart';
import '../models/account_choice.dart';
import '../models/onboarding_progress.dart';
import '../models/onboarding_result.dart';
import '../repositories/progress_repository.dart';

/// Thrown when onboarding is completed before personalise has been answered.
class OnboardingIncompleteException implements Exception {
  /// Creates the exception.
  const OnboardingIncompleteException();

  @override
  String toString() =>
      'OnboardingIncompleteException: personalise has not been answered.';
}

/// Marks onboarding finished and builds what the host receives.
class CompleteOnboarding {
  /// Creates the use case.
  const CompleteOnboarding(
    this._repository, [
    this._canAdvance = const CanAdvance(),
  ]);

  final ProgressRepository _repository;
  final CanAdvance _canAdvance;

  /// Runs it.
  ///
  /// Throws [OnboardingIncompleteException] when the flow has a personalise
  /// step that [progress] has not satisfied.
  Future<OnboardingResult> call(
    OnboardingFlow flow,
    OnboardingProgress progress,
  ) async {
    if (flow.contains(OnboardingStepKind.personalise) &&
        !_canAdvance(flow, progress, OnboardingStepKind.personalise)) {
      throw const OnboardingIncompleteException();
    }
    try {
      await _repository.write(
        progress.copyWith(step: flow.last.kind, completed: true),
      );
    } on Object {
      // Not being able to save never blocks the hand-off.
    }
    return OnboardingResult(
      interests: <String>[
        for (final Interest i in flow.interests)
          if (progress.interests.contains(i.id)) i.id,
      ],
      goalId: flow.goal(progress.goalId)?.id,
      reminderId: flow.reminder(progress.reminderId)?.id,
      permissions: Map.of(progress.permissions),
      accountChoice: progress.accountChoice ?? AccountChoice.guest,
    );
  }
}
