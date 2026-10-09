import 'package:equatable/equatable.dart';

/// The kinds of step the flow is made of.
///
/// The order and the selection of steps is content (see `OnboardingFlow.steps`):
/// leave one out of the JSON and it is not shown.
enum OnboardingStepKind {
  /// The swipeable value pages.
  welcome,

  /// Notifications, location and camera cards.
  permissions,

  /// Interests, goal and reminders.
  personalise,

  /// Create an account, sign in or continue as a guest.
  account,

  /// The summary and the Start button. Always the last step.
  done;

  /// The kind stored under [key], or `null` when it is unknown.
  static OnboardingStepKind? fromKey(String? key) {
    for (final OnboardingStepKind kind in values) {
      if (kind.name == key) return kind;
    }
    return null;
  }
}

/// One step of the flow, with the copy for its heading.
class OnboardingStep extends Equatable {
  /// Creates a step.
  const OnboardingStep({
    required this.kind,
    this.title = '',
    this.body = '',
    this.skippable = true,
  });

  /// What the step is.
  final OnboardingStepKind kind;

  /// The heading. Empty for the welcome step, whose pages carry their own.
  final String title;

  /// The line under the heading.
  final String body;

  /// Whether the content asks for a skip control on this step.
  final bool skippable;

  /// Whether the user may skip the step.
  ///
  /// Personalise can never be skipped: the interests it collects are validated
  /// before the flow moves on, whatever the content says. The done step has
  /// nothing to skip.
  bool get canSkip =>
      skippable &&
      kind != OnboardingStepKind.personalise &&
      kind != OnboardingStepKind.done;

  @override
  List<Object?> get props => <Object?>[kind, title, body, skippable];
}
