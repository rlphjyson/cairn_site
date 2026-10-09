import 'package:equatable/equatable.dart';

import '../../../domain/personalise/models/interests_validation.dart';

/// The answers being given on the personalise step, and which are in error.
class PersonaliseState extends Equatable {
  /// Creates a state.
  const PersonaliseState({
    this.interests = const <String>{},
    this.goalId,
    this.reminderId,
    this.validation = const InterestsValidation(count: 0, min: 0),
    this.showInterestsError = false,
    this.showGoalError = false,
  });

  /// The chosen interest ids.
  final Set<String> interests;

  /// The chosen goal id.
  final String? goalId;

  /// The chosen reminder option id.
  final String? reminderId;

  /// How the interests stand against the minimum.
  final InterestsValidation validation;

  /// Whether to tell the user more interests are needed. Only set after they
  /// tried to continue, so the screen is not shouting before they start.
  final bool showInterestsError;

  /// Whether to tell the user a goal is needed.
  final bool showGoalError;

  /// A copy with changes.
  PersonaliseState copyWith({
    Set<String>? interests,
    String? goalId,
    String? reminderId,
    InterestsValidation? validation,
    bool? showInterestsError,
    bool? showGoalError,
  }) => PersonaliseState(
    interests: interests ?? this.interests,
    goalId: goalId ?? this.goalId,
    reminderId: reminderId ?? this.reminderId,
    validation: validation ?? this.validation,
    showInterestsError: showInterestsError ?? this.showInterestsError,
    showGoalError: showGoalError ?? this.showGoalError,
  );

  @override
  List<Object?> get props => <Object?>[
    interests,
    goalId,
    reminderId,
    validation,
    showInterestsError,
    showGoalError,
  ];
}
