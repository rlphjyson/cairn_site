import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/constants/personalise_sections.dart';
import '../../../core/infrastructure/onboarding_hooks.dart';
import '../../../core/presentation/navigation/onboarding_navigation_cubit.dart';
import '../../../domain/flow/models/onboarding_flow.dart';
import '../../../domain/flow/models/onboarding_step.dart';
import '../../../domain/flow/use_cases/can_advance.dart';
import '../../../domain/flow/use_cases/get_next_step.dart';
import '../../../domain/flow/use_cases/get_onboarding_flow.dart';
import '../../../domain/flow/use_cases/get_previous_step.dart';
import '../../../domain/permissions/models/permission_kind.dart';
import '../../../domain/permissions/models/permission_status.dart';
import '../../../domain/permissions/use_cases/open_permission_settings.dart';
import '../../../domain/permissions/use_cases/request_permission.dart';
import '../../../domain/progress/models/account_choice.dart';
import '../../../domain/progress/models/onboarding_progress.dart';
import '../../../domain/progress/models/onboarding_result.dart';
import '../../../domain/progress/use_cases/complete_onboarding.dart';
import '../../../domain/progress/use_cases/reset_progress.dart';
import '../../../domain/progress/use_cases/resume_progress.dart';
import '../../../domain/progress/use_cases/save_progress.dart';
import 'onboarding_state.dart';

/// The onboarding session: loads the content, resumes saved progress, records
/// what the user does, saves it, and moves the navigation cubit between steps.
///
/// A lazy singleton owned by the container and provided to the tree with
/// `BlocProvider.value`; no view model closes it. It is the only cubit that
/// tells [OnboardingNavigationCubit] what to show.
class OnboardingCubit extends Cubit<OnboardingState> {
  /// Creates the cubit.
  OnboardingCubit({
    required this._getFlow,
    required ResumeProgress resumeProgress,
    required SaveProgress saveProgress,
    required ResetProgress resetProgress,
    required RequestPermission requestPermission,
    required OpenPermissionSettings openPermissionSettings,
    required CompleteOnboarding completeOnboarding,
    required GetNextStep getNextStep,
    required GetPreviousStep getPreviousStep,
    required this._canAdvance,
    required this._navigation,
    required this._hooks,
    this.startAtStep,
  }) : _resume = resumeProgress,
       _save = saveProgress,
       _reset = resetProgress,
       _request = requestPermission,
       _openSettings = openPermissionSettings,
       _complete = completeOnboarding,
       _getNext = getNextStep,
       _getPrevious = getPreviousStep,
       super(const OnboardingState());

  final GetOnboardingFlow _getFlow;
  final ResumeProgress _resume;
  final SaveProgress _save;
  final ResetProgress _reset;
  final RequestPermission _request;
  final OpenPermissionSettings _openSettings;
  final CompleteOnboarding _complete;
  final GetNextStep _getNext;
  final GetPreviousStep _getPrevious;
  final CanAdvance _canAdvance;
  final OnboardingNavigationCubit _navigation;
  final OnboardingHooks _hooks;

  /// When set, the splash screen is skipped and the flow opens on this step
  /// (if the flow has it).
  final OnboardingStepKind? startAtStep;

  static final int _lastSection = PersonaliseSection.values.length - 1;

  /// Loads the content and the saved progress.
  Future<void> load() async {
    emit(state.copyWith(status: OnboardingStatus.loading));
    try {
      final OnboardingFlow flow = await _getFlow();
      OnboardingProgress progress = await _resume(flow);
      final OnboardingStepKind? start = startAtStep;
      if (start != null && flow.contains(start)) {
        progress = progress.copyWith(step: start);
      }
      if (isClosed) return;
      emit(
        state.copyWith(
          status: OnboardingStatus.ready,
          flow: flow,
          progress: progress,
        ),
      );
      if (start != null && flow.contains(start)) _show(start);
    } on Object {
      if (isClosed) return;
      emit(state.copyWith(status: OnboardingStatus.failure));
    }
  }

  /// Leaves the splash screen for the step the user was on. Does nothing
  /// until the content has loaded, or once the splash screen is gone.
  void begin() {
    if (state.status != OnboardingStatus.ready) return;
    if (_navigation.state.step != null) return;
    _show(state.progress.step);
  }

  /// Records the welcome page the user reached.
  Future<void> setPage(int index) {
    final OnboardingFlow? flow = state.flow;
    if (flow == null || flow.pages.isEmpty) return Future<void>.value();
    final int page = index.clamp(0, flow.pages.length - 1);
    if (page == state.progress.pageIndex) return Future<void>.value();
    return _update(state.progress.copyWith(pageIndex: page));
  }

  /// Asks for [kind] and records the answer.
  Future<void> requestPermission(PermissionKind kind) async {
    if (state.pendingPermission != null) return;
    emit(state.copyWith(pendingPermission: kind));
    final PermissionStatus status = await _request(kind);
    if (isClosed) return;
    emit(state.copyWith(clearPending: true));
    await _update(
      state.progress.copyWith(
        permissions: <PermissionKind, PermissionStatus>{
          ...state.progress.permissions,
          kind: status,
        },
      ),
    );
  }

  /// Opens the system settings, where a refused permission can be turned on.
  Future<void> openSettings() => _openSettings();

  /// Records the personalise answers. Called as the user makes them, so a
  /// restart mid-way keeps them.
  Future<void> savePersonalisation({
    required Set<String> interests,
    required String? goalId,
    required String? reminderId,
  }) {
    final OnboardingProgress current = state.progress;
    return _update(
      current.copyWith(
        interests: interests,
        goalId: goalId,
        reminderId: reminderId,
        clearGoal: goalId == null,
        clearReminder: reminderId == null,
      ),
    );
  }

  /// Records the account choice and moves on.
  Future<void> chooseAccount(AccountChoice choice) async {
    await _update(state.progress.copyWith(accountChoice: choice));
    await next();
  }

  /// Moves forward: to the next part of the personalise step, or the next step.
  ///
  /// Does nothing when the progress rules say the user is not done yet.
  Future<void> next() async {
    final OnboardingFlow? flow = state.flow;
    if (flow == null) return;
    final OnboardingProgress progress = state.progress;
    if (progress.step == OnboardingStepKind.personalise &&
        progress.section < _lastSection) {
      await _update(progress.copyWith(section: progress.section + 1));
      return;
    }
    if (!_canAdvance(flow, progress, progress.step)) return;
    final OnboardingStepKind? target = _getNext(flow, progress.step);
    if (target == null) return;
    await _go(target, forward: true);
  }

  /// Skips the current step, when it may be skipped.
  ///
  /// Skipping the welcome pages or the permissions leaves what the user has
  /// already answered in place. Personalise can never be skipped.
  Future<void> skip() async {
    final OnboardingFlow? flow = state.flow;
    if (flow == null) return;
    final OnboardingStepKind step = state.progress.step;
    final OnboardingStep? definition = flow.step(step);
    if (definition == null || !definition.canSkip) return;
    final OnboardingStepKind? target = _getNext(flow, step);
    if (target == null) return;
    _hooks.onSkipped?.call(step);
    await _go(target, forward: true);
  }

  /// Moves back: to the previous page or part, or the previous step. Returns
  /// `false` when there is nowhere to go, so the system can handle the back
  /// press itself.
  bool back() {
    final OnboardingFlow? flow = state.flow;
    if (flow == null) return false;
    final OnboardingProgress progress = state.progress;
    if (progress.step == OnboardingStepKind.welcome && progress.pageIndex > 0) {
      unawaited(setPage(progress.pageIndex - 1));
      return true;
    }
    if (progress.step == OnboardingStepKind.personalise &&
        progress.section > 0) {
      unawaited(_update(progress.copyWith(section: progress.section - 1)));
      return true;
    }
    final OnboardingStepKind? target = _getPrevious(flow, progress.step);
    if (target == null) return false;
    unawaited(_go(target, forward: false));
    return true;
  }

  /// Whether [back] has somewhere to go.
  bool get canGoBack {
    final OnboardingFlow? flow = state.flow;
    if (flow == null || _navigation.state.step == null) return false;
    final OnboardingProgress p = state.progress;
    if (p.step == OnboardingStepKind.welcome && p.pageIndex > 0) return true;
    if (p.step == OnboardingStepKind.personalise && p.section > 0) return true;
    return _getPrevious(flow, p.step) != null;
  }

  /// Finishes onboarding and hands the result to the host.
  Future<OnboardingResult?> complete() async {
    final OnboardingFlow? flow = state.flow;
    if (flow == null || state.result != null) return state.result;
    try {
      final OnboardingResult result = await _complete(flow, state.progress);
      if (isClosed) return result;
      emit(
        state.copyWith(
          progress: state.progress.copyWith(completed: true),
          result: result,
        ),
      );
      _hooks.onCompleted?.call(result);
      return result;
    } on OnboardingIncompleteException {
      // The rules were not met; send the user back to answer them.
      await _go(OnboardingStepKind.personalise, forward: false);
      return null;
    }
  }

  /// Forgets everything and starts again from the first step. The demo's
  /// "replay".
  Future<void> restart() async {
    final OnboardingFlow? flow = state.flow;
    if (flow == null) return;
    await _reset();
    if (isClosed) return;
    emit(
      OnboardingState(
        status: OnboardingStatus.ready,
        flow: flow,
        progress: OnboardingProgress(
          step: flow.first.kind,
          reminderId: flow.reminder(flow.defaultReminderId)?.id,
        ),
      ),
    );
    _show(flow.first.kind, forward: false);
  }

  Future<void> _go(OnboardingStepKind step, {required bool forward}) async {
    final OnboardingProgress next = state.progress.copyWith(
      step: step,
      section: step == OnboardingStepKind.personalise && forward ? 0 : null,
    );
    emit(state.copyWith(progress: next));
    _show(step, forward: forward);
    await _save(next);
  }

  Future<void> _update(OnboardingProgress progress) async {
    if (progress == state.progress) return;
    emit(state.copyWith(progress: progress));
    await _save(progress);
  }

  void _show(OnboardingStepKind step, {bool forward = true}) {
    _navigation.show(step, forward: forward);
    _hooks.onStepChanged?.call(step);
  }
}
