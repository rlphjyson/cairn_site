import 'package:equatable/equatable.dart';

import '../../../domain/flow/models/onboarding_flow.dart';
import '../../../domain/flow/models/onboarding_step.dart';
import '../../../domain/permissions/models/permission_kind.dart';
import '../../../domain/progress/models/onboarding_progress.dart';
import '../../../domain/progress/models/onboarding_result.dart';

/// Whether the flow's content has loaded.
enum OnboardingStatus {
  /// Loading the content and the saved progress.
  loading,

  /// Ready to show.
  ready,

  /// Loading failed; the splash screen offers a retry.
  failure,
}

/// The whole onboarding session: its content and what the user has done.
class OnboardingState extends Equatable {
  /// Creates a state.
  const OnboardingState({
    this.status = OnboardingStatus.loading,
    this.flow,
    this.progress = const OnboardingProgress(),
    this.pendingPermission,
    this.result,
  });

  /// Whether the content has loaded.
  final OnboardingStatus status;

  /// The content, once loaded.
  final OnboardingFlow? flow;

  /// What the user has done so far.
  final OnboardingProgress progress;

  /// The permission whose system prompt is open, if any.
  final PermissionKind? pendingPermission;

  /// Set once the user has pressed Start.
  final OnboardingResult? result;

  /// The step the user is on, as the flow describes it.
  OnboardingStep? get currentStep => flow?.step(progress.step);

  /// How far through the flow the user is, from 0 to 1. Counts the current
  /// step as reached, so the first screen shows a sliver of progress.
  double get fraction {
    final OnboardingFlow? f = flow;
    if (f == null) return 0;
    final int i = f.indexOf(progress.step);
    if (i < 0) return 0;
    return (i + 1) / f.steps.length;
  }

  /// A copy with changes.
  OnboardingState copyWith({
    OnboardingStatus? status,
    OnboardingFlow? flow,
    OnboardingProgress? progress,
    PermissionKind? pendingPermission,
    bool clearPending = false,
    OnboardingResult? result,
    bool clearResult = false,
  }) => OnboardingState(
    status: status ?? this.status,
    flow: flow ?? this.flow,
    progress: progress ?? this.progress,
    pendingPermission: clearPending
        ? null
        : pendingPermission ?? this.pendingPermission,
    result: clearResult ? null : result ?? this.result,
  );

  @override
  List<Object?> get props => <Object?>[
    status,
    flow,
    progress,
    pendingPermission,
    result,
  ];
}
