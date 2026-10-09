import 'package:equatable/equatable.dart';

import '../../flow/models/onboarding_step.dart';
import '../../permissions/models/permission_kind.dart';
import '../../permissions/models/permission_status.dart';
import 'account_choice.dart';

/// Everything the user has done so far. It is what gets saved, so that
/// re-opening the app continues where they left off.
class OnboardingProgress extends Equatable {
  /// Creates progress.
  const OnboardingProgress({
    this.step = OnboardingStepKind.welcome,
    this.pageIndex = 0,
    this.section = 0,
    this.permissions = const <PermissionKind, PermissionStatus>{},
    this.interests = const <String>{},
    this.goalId,
    this.reminderId,
    this.accountChoice,
    this.completed = false,
  });

  /// The step the user is on.
  final OnboardingStepKind step;

  /// The page of the welcome carousel they reached.
  final int pageIndex;

  /// The part of the personalise step they reached: 0 interests, 1 goal,
  /// 2 reminders.
  final int section;

  /// The answer given to each permission asked for.
  final Map<PermissionKind, PermissionStatus> permissions;

  /// The chosen interest ids.
  final Set<String> interests;

  /// The chosen goal id.
  final String? goalId;

  /// The chosen reminder option id.
  final String? reminderId;

  /// The account choice.
  final AccountChoice? accountChoice;

  /// Whether the user pressed Start.
  final bool completed;

  /// The status of [kind].
  PermissionStatus statusOf(PermissionKind kind) =>
      permissions[kind] ?? PermissionStatus.notDetermined;

  /// A copy with changes. Pass `clearGoal`, `clearReminder` or `clearAccount`
  /// to reset those, since `null` means "keep".
  OnboardingProgress copyWith({
    OnboardingStepKind? step,
    int? pageIndex,
    int? section,
    Map<PermissionKind, PermissionStatus>? permissions,
    Set<String>? interests,
    String? goalId,
    String? reminderId,
    AccountChoice? accountChoice,
    bool? completed,
    bool clearGoal = false,
    bool clearReminder = false,
    bool clearAccount = false,
  }) => OnboardingProgress(
    step: step ?? this.step,
    pageIndex: pageIndex ?? this.pageIndex,
    section: section ?? this.section,
    permissions: permissions ?? this.permissions,
    interests: interests ?? this.interests,
    goalId: clearGoal ? null : goalId ?? this.goalId,
    reminderId: clearReminder ? null : reminderId ?? this.reminderId,
    accountChoice: clearAccount ? null : accountChoice ?? this.accountChoice,
    completed: completed ?? this.completed,
  );

  @override
  List<Object?> get props => <Object?>[
    step,
    pageIndex,
    section,
    permissions,
    interests,
    goalId,
    reminderId,
    accountChoice,
    completed,
  ];
}
