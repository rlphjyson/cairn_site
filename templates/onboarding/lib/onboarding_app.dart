import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import 'core/infrastructure/di/onboarding_injection.dart';
import 'core/infrastructure/onboarding_hooks.dart';
import 'core/presentation/view_model.dart';
import 'core/presentation/widgets/onboarding_column.dart';
import 'data/flow/remote/flow_remote_data_source.dart';
import 'data/progress/local/progress_store.dart';
import 'domain/flow/models/onboarding_step.dart';
import 'domain/permissions/repositories/permission_service.dart';
import 'domain/progress/models/onboarding_result.dart';
import 'presentation/flow/bloc/onboarding_cubit.dart';
import 'presentation/shell/onboarding_providers.dart';
import 'presentation/shell/onboarding_shell.dart';

/// A mobile onboarding flow, built only from `cairn_ui` and Cairn tokens.
///
/// A splash screen, a swipeable set of value pages, permission cards, a short
/// personalisation (interests, a goal, reminders), an account choice and a
/// calm summary. Progress is saved after every change, so re-opening the app
/// continues where the user left off.
///
/// Everything a host needs to change is injected, so the template never has to
/// be forked:
///
/// * [flowDataSource] supplies the content (pages, copy, interests);
/// * [progressStore] persists progress;
/// * [permissionService] asks the platform for permissions;
/// * [onCompleted], [onSkipped] and [onStepChanged] tell the host what the user
///   did.
///
/// It fills whatever space it is given up to a phone's width and stays a
/// centred column on anything wider. It is organised as clean architecture, by
/// layer and then by feature; see the README next to this file. Photographs are
/// from Pexels, used under the Pexels licence.
class OnboardingApp extends StatefulWidget {
  /// Creates the app.
  const OnboardingApp({
    super.key,
    this.onCompleted,
    this.onSkipped,
    this.onStepChanged,
    this.flowDataSource,
    this.progressStore,
    this.permissionService,
    this.startAtStep,
    this.showReplay = false,
  });

  /// Called once when the user presses Start on the last step. The result says
  /// what they chose, including [OnboardingResult.accountChoice], which tells
  /// the host where to send them next.
  final void Function(OnboardingResult result)? onCompleted;

  /// Called when the user skips a step, with the step skipped. Informational:
  /// the flow moves on by itself. Personalise cannot be skipped.
  final void Function(OnboardingStepKind step)? onSkipped;

  /// Called whenever a step is shown. Useful for analytics.
  final void Function(OnboardingStepKind step)? onStepChanged;

  /// Where the content comes from. Defaults to the in-memory demo content in
  /// `InMemoryFlowRemoteDataSource`.
  final FlowRemoteDataSource? flowDataSource;

  /// Where progress is kept. Defaults to an `InMemoryProgressStore`, which
  /// forgets everything when the app closes; pass a persistent one to resume
  /// across launches.
  final ProgressStore? progressStore;

  /// How permissions are requested. Defaults to the `DemoPermissionService`,
  /// which grants everything without a system prompt.
  final PermissionService? permissionService;

  /// Opens the flow on this step instead of showing the splash screen. The
  /// step must be one the content includes. It is read once, when the app is
  /// first built.
  final OnboardingStepKind? startAtStep;

  /// Whether the last step offers "Replay from the start". For demos; leave it
  /// off in a real app.
  final bool showReplay;

  @override
  State<OnboardingApp> createState() => _OnboardingAppState();
}

class _OnboardingAppState extends State<OnboardingApp> {
  late final OnboardingHooks _hooks = OnboardingHooks(
    onCompleted: widget.onCompleted,
    onSkipped: widget.onSkipped,
    onStepChanged: widget.onStepChanged,
  );

  late final GetIt _locator = createOnboardingLocator(
    flowDataSource: widget.flowDataSource,
    progressStore: widget.progressStore,
    permissionService: widget.permissionService,
    startAtStep: widget.startAtStep,
    hooks: _hooks,
  );

  @override
  void initState() {
    super.initState();
    unawaited(_locator<OnboardingCubit>().load());
  }

  @override
  void didUpdateWidget(OnboardingApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The callbacks may change between builds without restarting the flow.
    _hooks
      ..onCompleted = widget.onCompleted
      ..onSkipped = widget.onSkipped
      ..onStepChanged = widget.onStepChanged;
  }

  @override
  void dispose() {
    unawaited(_locator.reset());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => OnboardingScope(
    locator: _locator,
    child: OnboardingProviders(
      locator: _locator,
      child: OnboardingColumn(
        child: OnboardingShell(showReplay: widget.showReplay),
      ),
    ),
  );
}
