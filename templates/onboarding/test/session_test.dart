import 'package:cairn_template_onboarding/common/constants/personalise_sections.dart';
import 'package:cairn_template_onboarding/core/infrastructure/di/onboarding_injection.dart';
import 'package:cairn_template_onboarding/core/infrastructure/onboarding_hooks.dart';
import 'package:cairn_template_onboarding/core/presentation/navigation/onboarding_navigation_cubit.dart';
import 'package:cairn_template_onboarding/data/flow/remote/flow_remote_data_source.dart';
import 'package:cairn_template_onboarding/data/permissions/remote/demo_permission_service.dart';
import 'package:cairn_template_onboarding/data/progress/local/progress_store.dart';
import 'package:cairn_template_onboarding/domain/flow/models/onboarding_step.dart';
import 'package:cairn_template_onboarding/domain/permissions/models/permission_kind.dart';
import 'package:cairn_template_onboarding/domain/permissions/models/permission_status.dart';
import 'package:cairn_template_onboarding/domain/progress/models/account_choice.dart';
import 'package:cairn_template_onboarding/domain/progress/models/onboarding_result.dart';
import 'package:cairn_template_onboarding/presentation/flow/bloc/onboarding_cubit.dart';
import 'package:cairn_template_onboarding/presentation/flow/bloc/onboarding_state.dart';
import 'package:cairn_template_onboarding/presentation/personalise/bloc/personalise_cubit.dart';
import 'package:cairn_template_onboarding/presentation/personalise/view_models/personalise_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

/// The cubits wired through the real container, with no widgets: the point of
/// the layering is that the whole flow runs without a UI.
void main() {
  late GetIt locator;
  late InMemoryProgressStore store;
  late DemoPermissionService permissions;
  late List<OnboardingResult> completed;
  late List<OnboardingStepKind> skipped;
  late List<OnboardingStepKind> shown;

  GetIt build({
    FlowRemoteDataSource? flow,
    OnboardingStepKind? startAtStep,
    InMemoryProgressStore? withStore,
  }) => createOnboardingLocator(
    flowDataSource: flow,
    progressStore: withStore ?? store,
    permissionService: permissions,
    startAtStep: startAtStep,
    hooks: OnboardingHooks(
      onCompleted: completed.add,
      onSkipped: skipped.add,
      onStepChanged: shown.add,
    ),
  );

  setUp(() {
    store = InMemoryProgressStore();
    permissions = DemoPermissionService();
    completed = <OnboardingResult>[];
    skipped = <OnboardingStepKind>[];
    shown = <OnboardingStepKind>[];
    locator = build();
  });
  tearDown(() => locator.reset());

  OnboardingCubit cubit() => locator<OnboardingCubit>();
  OnboardingNavigationCubit nav() => locator<OnboardingNavigationCubit>();
  OnboardingStepKind? step() => nav().state.step;

  Future<void> loadAndBegin() async {
    await cubit().load();
    cubit().begin();
  }

  Future<void> answerPersonalise() async {
    await cubit().savePersonalisation(
      interests: <String>{'focus', 'sleep', 'music'},
      goalId: 'calm',
      reminderId: 'morning',
    );
  }

  group('container', () {
    test('each container is independent', () {
      final GetIt other = createOnboardingLocator();
      expect(
        identical(
          locator<OnboardingNavigationCubit>(),
          other<OnboardingNavigationCubit>(),
        ),
        isFalse,
      );
      other.reset();
    });

    test('session cubits are singletons; screen cubits are not', () {
      expect(identical(cubit(), locator<OnboardingCubit>()), isTrue);
      expect(identical(nav(), locator<OnboardingNavigationCubit>()), isTrue);
      expect(
        identical(
          locator<PersonaliseViewModel>().cubit,
          locator<PersonaliseViewModel>().cubit,
        ),
        isFalse,
      );
    });

    test('a view model closes its cubit', () {
      final PersonaliseViewModel vm = locator<PersonaliseViewModel>();
      expect(vm.cubit.isClosed, isFalse);
      vm.dispose();
      expect(vm.cubit.isClosed, isTrue);
    });

    test('the injected integration points are the ones used', () {
      expect(locator<ProgressStore>(), same(store));
      expect(
        locator<FlowRemoteDataSource>(),
        isA<InMemoryFlowRemoteDataSource>(),
      );
    });

    test('resetting the container closes the session cubits', () async {
      final OnboardingCubit c = cubit();
      await locator.reset();
      expect(c.isClosed, isTrue);
    });
  });

  group('loading', () {
    test('starts loading, shows the splash, then is ready', () async {
      expect(cubit().state.status, OnboardingStatus.loading);
      expect(step(), isNull);
      await cubit().load();
      expect(cubit().state.status, OnboardingStatus.ready);
      expect(cubit().state.flow!.pages, hasLength(4));
      // Still on the splash until it asks to begin.
      expect(step(), isNull);
      cubit().begin();
      expect(step(), OnboardingStepKind.welcome);
      expect(shown, <OnboardingStepKind>[OnboardingStepKind.welcome]);
    });

    test('begin before the content has loaded does nothing', () {
      cubit().begin();
      expect(step(), isNull);
    });

    test('begin is a no-op once the flow has started', () async {
      await loadAndBegin();
      await cubit().next();
      cubit().begin();
      expect(step(), OnboardingStepKind.permissions);
    });

    test('a failing data source reports failure, and load can retry', () async {
      final _Flaky flaky = _Flaky();
      await locator.reset();
      locator = build(flow: flaky);
      await cubit().load();
      expect(cubit().state.status, OnboardingStatus.failure);
      cubit().begin();
      expect(step(), isNull);
      flaky.fail = false;
      await cubit().load();
      expect(cubit().state.status, OnboardingStatus.ready);
    });

    test('progress fraction grows with the step', () async {
      await loadAndBegin();
      final double first = cubit().state.fraction;
      await cubit().next();
      expect(cubit().state.fraction, greaterThan(first));
      expect(first, closeTo(0.2, 1e-9));
    });
  });

  group('welcome', () {
    test('pages are recorded, clamped and saved', () async {
      await loadAndBegin();
      await cubit().setPage(2);
      expect(cubit().state.progress.pageIndex, 2);
      await cubit().setPage(99);
      expect(cubit().state.progress.pageIndex, 3);
      await cubit().setPage(-4);
      expect(cubit().state.progress.pageIndex, 0);
      await cubit().setPage(1);
      expect((await store.read())!['pageIndex'], 1);
    });

    test('back steps through pages, then has nowhere to go', () async {
      await loadAndBegin();
      expect(cubit().canGoBack, isFalse);
      expect(cubit().back(), isFalse);
      await cubit().setPage(2);
      expect(cubit().canGoBack, isTrue);
      expect(cubit().back(), isTrue);
      await Future<void>.delayed(Duration.zero);
      expect(cubit().state.progress.pageIndex, 1);
    });

    test('skip jumps to permissions and reports it', () async {
      await loadAndBegin();
      await cubit().skip();
      expect(step(), OnboardingStepKind.permissions);
      expect(skipped, <OnboardingStepKind>[OnboardingStepKind.welcome]);
    });
  });

  group('permissions', () {
    Future<void> toPermissions() async {
      await loadAndBegin();
      await cubit().next();
    }

    test('allowing records the answer and saves it', () async {
      await toPermissions();
      await cubit().requestPermission(PermissionKind.notifications);
      expect(
        cubit().state.progress.statusOf(PermissionKind.notifications),
        PermissionStatus.granted,
      );
      expect(cubit().state.pendingPermission, isNull);
      expect((await store.read())!['permissions'], <String, Object?>{
        'notifications': 'granted',
      });
    });

    test('declining is recorded too, and the user can still go on', () async {
      await locator.reset();
      permissions = DemoPermissionService(
        answers: <PermissionKind, PermissionStatus>{
          PermissionKind.location: PermissionStatus.permanentlyDenied,
        },
      );
      locator = build();
      await toPermissions();
      await cubit().requestPermission(PermissionKind.location);
      expect(
        cubit().state.progress.statusOf(PermissionKind.location),
        PermissionStatus.permanentlyDenied,
      );
      await cubit().next();
      expect(step(), OnboardingStepKind.personalise);
    });

    test('one prompt at a time', () async {
      await locator.reset();
      permissions = DemoPermissionService(
        latency: const Duration(milliseconds: 20),
      );
      locator = build();
      await toPermissions();
      final Future<void> first = cubit().requestPermission(
        PermissionKind.notifications,
      );
      expect(cubit().state.pendingPermission, PermissionKind.notifications);
      await cubit().requestPermission(PermissionKind.location);
      await first;
      expect(
        cubit().state.progress.statusOf(PermissionKind.location),
        PermissionStatus.notDetermined,
      );
    });

    test('skipping asks for nothing', () async {
      await toPermissions();
      await cubit().skip();
      expect(step(), OnboardingStepKind.personalise);
      expect(cubit().state.progress.permissions, isEmpty);
      expect(skipped.last, OnboardingStepKind.permissions);
    });

    test('settings can be opened', () async {
      await toPermissions();
      await cubit().openSettings();
      expect(permissions.settingsOpened, 1);
    });
  });

  group('personalise', () {
    Future<void> toPersonalise() async {
      await loadAndBegin();
      await cubit().next();
      await cubit().next();
    }

    test('cannot be skipped', () async {
      await toPersonalise();
      await cubit().skip();
      expect(step(), OnboardingStepKind.personalise);
      expect(skipped, isEmpty);
    });

    test('next moves through the three parts, then the rules apply', () async {
      await toPersonalise();
      expect(cubit().state.progress.section, 0);
      await cubit().next();
      await cubit().next();
      expect(cubit().state.progress.section, 2);
      // Nothing answered: the last part will not hand over to the next step.
      await cubit().next();
      expect(step(), OnboardingStepKind.personalise);
      await answerPersonalise();
      await cubit().next();
      expect(step(), OnboardingStepKind.account);
    });

    test('too few interests keep the user here', () async {
      await toPersonalise();
      await cubit().savePersonalisation(
        interests: <String>{'focus', 'sleep'},
        goalId: 'calm',
        reminderId: 'morning',
      );
      await cubit().next();
      await cubit().next();
      await cubit().next();
      expect(step(), OnboardingStepKind.personalise);
    });

    test('back steps through the parts before leaving the step', () async {
      await toPersonalise();
      await cubit().next();
      expect(cubit().back(), isTrue);
      await Future<void>.delayed(Duration.zero);
      expect(cubit().state.progress.section, 0);
      expect(cubit().back(), isTrue);
      await Future<void>.delayed(Duration.zero);
      expect(step(), OnboardingStepKind.permissions);
      expect(nav().state.forward, isFalse);
    });

    test('answers are saved as they are made', () async {
      await toPersonalise();
      await answerPersonalise();
      final Map<String, Object?> json = (await store.read())!;
      expect(json['interests'], <Object?>['focus', 'sleep', 'music']);
      expect(json['goalId'], 'calm');
    });

    test(
      'the draft cubit seeds from progress and validates each part',
      () async {
        await toPersonalise();
        await cubit().savePersonalisation(
          interests: <String>{'focus'},
          goalId: null,
          reminderId: 'weekly',
        );
        final PersonaliseCubit draft = locator<PersonaliseViewModel>().cubit
          ..start(cubit().state.flow!, cubit().state.progress);
        expect(draft.state.interests, <String>{'focus'});
        expect(draft.state.reminderId, 'weekly');
        expect(draft.state.validation.missing, 2);

        // Not yet valid: the error is switched on, only when asked.
        expect(draft.state.showInterestsError, isFalse);
        expect(draft.validate(PersonaliseSection.interests), isFalse);
        expect(draft.state.showInterestsError, isTrue);

        draft
          ..toggleInterest('sleep')
          ..toggleInterest('music');
        expect(draft.state.showInterestsError, isFalse);
        expect(draft.validate(PersonaliseSection.interests), isTrue);
        draft.toggleInterest('music');
        expect(draft.state.validation.isValid, isFalse);

        expect(draft.validate(PersonaliseSection.goal), isFalse);
        expect(draft.state.showGoalError, isTrue);
        draft.selectGoal('move');
        expect(draft.state.showGoalError, isFalse);
        expect(draft.validate(PersonaliseSection.goal), isTrue);

        expect(draft.validate(PersonaliseSection.reminders), isTrue);
        draft.selectReminder('none');
        expect(draft.state.reminderId, 'none');
        await draft.close();
      },
    );
  });

  group('account and completion', () {
    Future<void> toAccount() async {
      await loadAndBegin();
      await cubit().next();
      await cubit().next();
      await answerPersonalise();
      await cubit().next();
      await cubit().next();
      await cubit().next();
      expect(step(), OnboardingStepKind.account);
    }

    test(
      'choosing an account option records it and shows the summary',
      () async {
        await toAccount();
        await cubit().chooseAccount(AccountChoice.signIn);
        expect(step(), OnboardingStepKind.done);
        expect(cubit().state.progress.accountChoice, AccountChoice.signIn);
      },
    );

    test('skipping the account step means guest', () async {
      await toAccount();
      await cubit().skip();
      expect(step(), OnboardingStepKind.done);
      await cubit().complete();
      expect(completed.single.accountChoice, AccountChoice.guest);
      expect(skipped, <OnboardingStepKind>[OnboardingStepKind.account]);
    });

    test('complete hands the result to the host exactly once', () async {
      await toAccount();
      await cubit().requestPermission(PermissionKind.notifications);
      await cubit().chooseAccount(AccountChoice.createAccount);
      final OnboardingResult? result = await cubit().complete();
      expect(result, completed.single);
      expect(result!.interests, <String>['focus', 'sleep', 'music']);
      expect(result.accountChoice, AccountChoice.createAccount);
      expect(cubit().state.result, result);
      expect(cubit().state.progress.completed, isTrue);
      expect((await store.read())!['completed'], isTrue);

      await cubit().complete();
      expect(completed, hasLength(1));
    });

    test(
      'complete before personalise is answered sends the user back',
      () async {
        await loadAndBegin();
        await cubit().next();
        await cubit().next();
        expect(await cubit().complete(), isNull);
        expect(completed, isEmpty);
        expect(step(), OnboardingStepKind.personalise);
      },
    );

    test('nothing moves past the last step', () async {
      await toAccount();
      await cubit().skip();
      await cubit().next();
      await cubit().skip();
      expect(step(), OnboardingStepKind.done);
    });
  });

  group('resume and restart', () {
    test('a new container on the same store resumes mid-flow', () async {
      await loadAndBegin();
      await cubit().setPage(2);
      await cubit().next();
      await cubit().next();
      await cubit().savePersonalisation(
        interests: <String>{'focus', 'sleep'},
        goalId: null,
        reminderId: 'weekly',
      );
      await cubit().next();
      await locator.reset();

      shown.clear();
      locator = build();
      await loadAndBegin();
      expect(step(), OnboardingStepKind.personalise);
      expect(cubit().state.progress.section, 1);
      expect(cubit().state.progress.interests, <String>{'focus', 'sleep'});
      expect(cubit().state.progress.reminderId, 'weekly');
      expect(shown, <OnboardingStepKind>[OnboardingStepKind.personalise]);
    });

    test('startAtStep opens that step without the splash', () async {
      await locator.reset();
      locator = build(startAtStep: OnboardingStepKind.account);
      await cubit().load();
      expect(step(), OnboardingStepKind.account);
      expect(shown, <OnboardingStepKind>[OnboardingStepKind.account]);
    });

    test('startAtStep ignores a step the flow does not have', () async {
      await locator.reset();
      locator = build(startAtStep: OnboardingStepKind.account, flow: _Lean());
      await cubit().load();
      expect(step(), isNull);
    });

    test('restart forgets everything and returns to the first step', () async {
      await loadAndBegin();
      await cubit().setPage(3);
      await cubit().next();
      await cubit().requestPermission(PermissionKind.location);
      await cubit().restart();
      expect(await store.read(), isNull);
      expect(step(), OnboardingStepKind.welcome);
      expect(nav().state.forward, isFalse);
      expect(cubit().state.progress.pageIndex, 0);
      expect(cubit().state.progress.permissions, isEmpty);
      expect(cubit().state.result, isNull);
      expect(cubit().state.progress.reminderId, 'morning');
    });
  });

  group('content', () {
    test('a flow without steps the content leaves out skips them', () async {
      await locator.reset();
      locator = build(flow: _Lean());
      await loadAndBegin();
      expect(step(), OnboardingStepKind.welcome);
      await cubit().next();
      expect(step(), OnboardingStepKind.done);
      await cubit().complete();
      expect(completed.single.accountChoice, AccountChoice.guest);
    });
  });
}

class _Flaky implements FlowRemoteDataSource {
  bool fail = true;

  @override
  Future<Map<String, Object?>> fetchFlow() async {
    if (fail) throw StateError('offline');
    return InMemoryFlowRemoteDataSource.content;
  }
}

class _Lean implements FlowRemoteDataSource {
  @override
  Future<Map<String, Object?>> fetchFlow() async => <String, Object?>{
    ...InMemoryFlowRemoteDataSource.content,
    'steps': <Object?>[
      <String, Object?>{'kind': 'welcome'},
    ],
  };
}
