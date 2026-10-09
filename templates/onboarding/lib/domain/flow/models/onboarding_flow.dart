import 'package:equatable/equatable.dart';

import '../../permissions/models/permission_request.dart';
import '../../personalise/models/goal.dart';
import '../../personalise/models/interest.dart';
import '../../personalise/models/reminder_option.dart';
import 'onboarding_step.dart';
import 'value_page.dart';

/// Everything the onboarding shows: which steps, in which order, and the
/// content of each. It is the one thing to change, or to load from remote
/// config, to change what the onboarding says.
class OnboardingFlow extends Equatable {
  /// Creates a flow.
  const OnboardingFlow({
    required this.steps,
    required this.pages,
    required this.permissions,
    required this.interests,
    required this.goals,
    required this.reminders,
    this.minInterests = 3,
    this.defaultReminderId,
  });

  /// The steps, in order. The last is always [OnboardingStepKind.done].
  final List<OnboardingStep> steps;

  /// The welcome carousel.
  final List<ValuePage> pages;

  /// The permission cards.
  final List<PermissionRequest> permissions;

  /// The interests to choose from.
  final List<Interest> interests;

  /// The goals to choose from.
  final List<Goal> goals;

  /// The reminder options.
  final List<ReminderOption> reminders;

  /// How many interests the user has to pick.
  final int minInterests;

  /// The reminder option selected before the user chooses, or `null` for none.
  final String? defaultReminderId;

  /// The first step.
  OnboardingStep get first => steps.first;

  /// The last step.
  OnboardingStep get last => steps.last;

  /// The position of [kind] in [steps], or -1 when the flow has no such step.
  int indexOf(OnboardingStepKind kind) =>
      steps.indexWhere((OnboardingStep s) => s.kind == kind);

  /// Whether the flow includes [kind].
  bool contains(OnboardingStepKind kind) => indexOf(kind) >= 0;

  /// The step of [kind], or `null` when the flow has none.
  OnboardingStep? step(OnboardingStepKind kind) {
    final int i = indexOf(kind);
    return i < 0 ? null : steps[i];
  }

  /// The interest with [id], or `null`.
  Interest? interest(String id) {
    for (final Interest i in interests) {
      if (i.id == id) return i;
    }
    return null;
  }

  /// The goal with [id], or `null`.
  Goal? goal(String? id) {
    for (final Goal g in goals) {
      if (g.id == id) return g;
    }
    return null;
  }

  /// The reminder option with [id], or `null`.
  ReminderOption? reminder(String? id) {
    for (final ReminderOption r in reminders) {
      if (r.id == id) return r;
    }
    return null;
  }

  @override
  List<Object?> get props => <Object?>[
    steps,
    pages,
    permissions,
    interests,
    goals,
    reminders,
    minInterests,
    defaultReminderId,
  ];
}
