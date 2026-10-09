import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/flow/models/onboarding_step.dart';

/// Where the user is: the splash screen, or one of the flow's steps.
class OnboardingNavigationState extends Equatable {
  /// Creates a state.
  const OnboardingNavigationState({this.step, this.forward = true});

  /// The current step, or `null` while the splash screen is showing.
  final OnboardingStepKind? step;

  /// Whether the last move went forward. The transition slides the new screen
  /// in from the matching side.
  final bool forward;

  @override
  List<Object?> get props => <Object?>[step, forward];
}

/// Navigation inside the onboarding.
///
/// The template deliberately does not use the host app's router: it has to run
/// unchanged inside any Flutter app, whatever that app uses for routing. The
/// flow cubit decides *which* step is next and tells this cubit to show it.
/// To drive the steps with `go_router` or `Navigator` instead, replace this
/// cubit and keep every view as it is (see `doc/index.html`).
class OnboardingNavigationCubit extends Cubit<OnboardingNavigationState> {
  /// Creates the cubit, showing the splash screen.
  OnboardingNavigationCubit() : super(const OnboardingNavigationState());

  /// Shows [step]. [forward] is `false` when going back.
  void show(OnboardingStepKind step, {bool forward = true}) =>
      emit(OnboardingNavigationState(step: step, forward: forward));
}
