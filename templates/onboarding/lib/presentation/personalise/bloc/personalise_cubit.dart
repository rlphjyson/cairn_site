import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/constants/personalise_sections.dart';
import '../../../domain/flow/models/onboarding_flow.dart';
import '../../../domain/personalise/models/interests_validation.dart';
import '../../../domain/personalise/use_cases/validate_interests.dart';
import '../../../domain/progress/models/onboarding_progress.dart';
import 'personalise_state.dart';

/// The draft answers on the personalise step.
///
/// Screen-scoped: created by `PersonaliseViewModel` when the step opens, seeded
/// from the saved progress, and closed with it. The view copies every change
/// to the session cubit, which saves it.
class PersonaliseCubit extends Cubit<PersonaliseState> {
  /// Creates the cubit.
  PersonaliseCubit(this._validateInterests) : super(const PersonaliseState());

  final ValidateInterests _validateInterests;
  OnboardingFlow? _flow;

  /// Seeds the draft from [progress].
  void start(OnboardingFlow flow, OnboardingProgress progress) {
    _flow = flow;
    emit(
      PersonaliseState(
        interests: progress.interests,
        goalId: progress.goalId,
        reminderId: progress.reminderId,
        validation: _check(progress.interests),
      ),
    );
  }

  /// Adds or removes [id].
  void toggleInterest(String id) {
    final Set<String> next = <String>{...state.interests};
    if (!next.remove(id)) next.add(id);
    final InterestsValidation validation = _check(next);
    emit(
      state.copyWith(
        interests: next,
        validation: validation,
        // Once the user is back in range the warning goes away on its own.
        showInterestsError: validation.isValid
            ? false
            : state.showInterestsError,
      ),
    );
  }

  /// Chooses the goal [id].
  void selectGoal(String id) =>
      emit(state.copyWith(goalId: id, showGoalError: false));

  /// Chooses the reminder option [id].
  void selectReminder(String id) => emit(state.copyWith(reminderId: id));

  /// Checks [section]. When it is not satisfied, turns on its error message and
  /// returns `false`.
  bool validate(PersonaliseSection section) {
    switch (section) {
      case PersonaliseSection.interests:
        final bool valid = state.validation.isValid;
        if (!valid) emit(state.copyWith(showInterestsError: true));
        return valid;
      case PersonaliseSection.goal:
        final bool valid = _flow == null || _flow!.goals.isEmpty
            ? true
            : _flow!.goal(state.goalId) != null;
        if (!valid) emit(state.copyWith(showGoalError: true));
        return valid;
      case PersonaliseSection.reminders:
        return canFinish;
    }
  }

  /// Whether a reminder option is chosen (or the flow offers none).
  bool get canFinish =>
      _flow == null ||
      _flow!.reminders.isEmpty ||
      _flow!.reminder(state.reminderId) != null;

  InterestsValidation _check(Set<String> interests) {
    final OnboardingFlow? flow = _flow;
    if (flow == null) {
      return InterestsValidation(count: interests.length, min: 0);
    }
    return _validateInterests(
      selected: interests,
      available: flow.interests,
      min: flow.minInterests,
    );
  }
}
