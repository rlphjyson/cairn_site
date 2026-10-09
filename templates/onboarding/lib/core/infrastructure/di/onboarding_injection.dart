import 'package:get_it/get_it.dart';

import '../../../data/flow/remote/flow_remote_data_source.dart';
import '../../../data/flow/repositories/flow_repository_impl.dart';
import '../../../data/permissions/remote/demo_permission_service.dart';
import '../../../data/progress/local/progress_store.dart';
import '../../../data/progress/repositories/progress_repository_impl.dart';
import '../../../domain/flow/models/onboarding_step.dart';
import '../../../domain/flow/repositories/flow_repository.dart';
import '../../../domain/flow/use_cases/can_advance.dart';
import '../../../domain/flow/use_cases/get_next_step.dart';
import '../../../domain/flow/use_cases/get_onboarding_flow.dart';
import '../../../domain/flow/use_cases/get_previous_step.dart';
import '../../../domain/permissions/repositories/permission_service.dart';
import '../../../domain/permissions/use_cases/open_permission_settings.dart';
import '../../../domain/permissions/use_cases/request_permission.dart';
import '../../../domain/personalise/use_cases/validate_interests.dart';
import '../../../domain/progress/repositories/progress_repository.dart';
import '../../../domain/progress/use_cases/complete_onboarding.dart';
import '../../../domain/progress/use_cases/reset_progress.dart';
import '../../../domain/progress/use_cases/resume_progress.dart';
import '../../../domain/progress/use_cases/save_progress.dart';
import '../../../presentation/flow/bloc/onboarding_cubit.dart';
import '../../../presentation/personalise/bloc/personalise_cubit.dart';
import '../../../presentation/personalise/view_models/personalise_view_model.dart';
import '../../presentation/navigation/onboarding_navigation_cubit.dart';
import '../onboarding_hooks.dart';

/// Builds a fresh dependency container for one mount of the template.
///
/// Registration is explicit rather than generated, so the template needs no
/// `build_runner` step. The scopes follow one rule:
///
/// * data sources, the permission service, repositories: singletons, one per
///   session;
/// * use cases: factories (they are stateless and free to build);
/// * **session cubits** (navigation, the onboarding flow): lazy singletons,
///   provided to the tree once and never closed by a view model;
/// * **screen cubits** (the personalise draft): created and closed by their
///   view model, which is a factory.
///
/// The three arguments are the template's integration points. Pass your own to
/// load the content remotely, to persist progress, or to ask the platform for
/// real permissions; anything left `null` gets the in-memory demo.
GetIt createOnboardingLocator({
  FlowRemoteDataSource? flowDataSource,
  ProgressStore? progressStore,
  PermissionService? permissionService,
  OnboardingStepKind? startAtStep,
  OnboardingHooks? hooks,
}) {
  final GetIt g = GetIt.asNewInstance();

  // Integration points. Replace these with ones that call your backend,
  // storage and the platform.
  g
    ..registerSingleton<OnboardingHooks>(hooks ?? OnboardingHooks())
    ..registerSingleton<FlowRemoteDataSource>(
      flowDataSource ?? const InMemoryFlowRemoteDataSource(),
    )
    ..registerSingleton<ProgressStore>(progressStore ?? InMemoryProgressStore())
    ..registerSingleton<PermissionService>(
      permissionService ?? DemoPermissionService(),
    );

  // Repositories.
  g
    ..registerLazySingleton<FlowRepository>(() => FlowRepositoryImpl(g()))
    ..registerLazySingleton<ProgressRepository>(
      () => ProgressRepositoryImpl(g()),
    );

  // Use cases.
  g
    ..registerFactory<GetOnboardingFlow>(() => GetOnboardingFlow(g()))
    ..registerFactory<ResumeProgress>(() => ResumeProgress(g()))
    ..registerFactory<SaveProgress>(() => SaveProgress(g()))
    ..registerFactory<ResetProgress>(() => ResetProgress(g()))
    ..registerFactory<RequestPermission>(() => RequestPermission(g()))
    ..registerFactory<OpenPermissionSettings>(() => OpenPermissionSettings(g()))
    ..registerFactory<ValidateInterests>(ValidateInterests.new)
    ..registerFactory<CanAdvance>(() => CanAdvance(g()))
    ..registerFactory<CompleteOnboarding>(() => CompleteOnboarding(g(), g()))
    ..registerFactory<GetNextStep>(GetNextStep.new)
    ..registerFactory<GetPreviousStep>(GetPreviousStep.new);

  // Session cubits.
  g
    ..registerLazySingleton<OnboardingNavigationCubit>(
      OnboardingNavigationCubit.new,
      dispose: (OnboardingNavigationCubit c) => c.close(),
    )
    ..registerLazySingleton<OnboardingCubit>(
      () => OnboardingCubit(
        getFlow: g(),
        resumeProgress: g(),
        saveProgress: g(),
        resetProgress: g(),
        requestPermission: g(),
        openPermissionSettings: g(),
        completeOnboarding: g(),
        getNextStep: g(),
        getPreviousStep: g(),
        canAdvance: g(),
        navigation: g(),
        hooks: g(),
        startAtStep: startAtStep,
      ),
      dispose: (OnboardingCubit c) => c.close(),
    );

  // Screen view models; each creates and owns its own cubit.
  g.registerFactory<PersonaliseViewModel>(
    () => PersonaliseViewModel(PersonaliseCubit(g())),
  );

  return g;
}
