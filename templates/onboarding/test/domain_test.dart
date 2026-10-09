import 'dart:io';

import 'package:cairn_template_onboarding/common/utils/lists.dart';
import 'package:cairn_template_onboarding/data/flow/remote/flow_remote_data_source.dart';
import 'package:cairn_template_onboarding/data/permissions/remote/demo_permission_service.dart';
import 'package:cairn_template_onboarding/data/progress/local/progress_store.dart';
import 'package:cairn_template_onboarding/data/progress/repositories/progress_repository_impl.dart';
import 'package:cairn_template_onboarding/domain/flow/mappers/flow_mapper.dart';
import 'package:cairn_template_onboarding/domain/flow/models/onboarding_flow.dart';
import 'package:cairn_template_onboarding/domain/flow/models/onboarding_step.dart';
import 'package:cairn_template_onboarding/domain/flow/use_cases/can_advance.dart';
import 'package:cairn_template_onboarding/domain/flow/use_cases/get_next_step.dart';
import 'package:cairn_template_onboarding/domain/flow/use_cases/get_previous_step.dart';
import 'package:cairn_template_onboarding/domain/permissions/models/permission_kind.dart';
import 'package:cairn_template_onboarding/domain/permissions/models/permission_status.dart';
import 'package:cairn_template_onboarding/domain/permissions/repositories/permission_service.dart';
import 'package:cairn_template_onboarding/domain/permissions/use_cases/open_permission_settings.dart';
import 'package:cairn_template_onboarding/domain/permissions/use_cases/request_permission.dart';
import 'package:cairn_template_onboarding/domain/personalise/models/interest.dart';
import 'package:cairn_template_onboarding/domain/personalise/use_cases/validate_interests.dart';
import 'package:cairn_template_onboarding/domain/progress/mappers/progress_mapper.dart';
import 'package:cairn_template_onboarding/domain/progress/models/account_choice.dart';
import 'package:cairn_template_onboarding/domain/progress/models/onboarding_progress.dart';
import 'package:cairn_template_onboarding/domain/progress/models/onboarding_result.dart';
import 'package:cairn_template_onboarding/domain/progress/repositories/progress_repository.dart';
import 'package:cairn_template_onboarding/domain/progress/use_cases/complete_onboarding.dart';
import 'package:cairn_template_onboarding/domain/progress/use_cases/reset_progress.dart';
import 'package:cairn_template_onboarding/domain/progress/use_cases/resume_progress.dart';
import 'package:cairn_template_onboarding/domain/progress/use_cases/save_progress.dart';
import 'package:flutter_test/flutter_test.dart';

OnboardingFlow demoFlow() =>
    FlowMapper.fromJson(InMemoryFlowRemoteDataSource.content);

const OnboardingProgress _answered = OnboardingProgress(
  step: OnboardingStepKind.personalise,
  interests: <String>{'focus', 'sleep', 'music'},
  goalId: 'calm',
  reminderId: 'morning',
);

void main() {
  group('flow content', () {
    test('the demo content maps to a full flow', () {
      final OnboardingFlow flow = demoFlow();
      expect(flow.steps.map((OnboardingStep s) => s.kind), <OnboardingStepKind>[
        OnboardingStepKind.welcome,
        OnboardingStepKind.permissions,
        OnboardingStepKind.personalise,
        OnboardingStepKind.account,
        OnboardingStepKind.done,
      ]);
      expect(flow.pages, hasLength(4));
      expect(flow.permissions.map((r) => r.kind), <PermissionKind>[
        PermissionKind.notifications,
        PermissionKind.location,
      ]);
      expect(flow.interests.length, greaterThanOrEqualTo(8));
      expect(flow.goals, hasLength(4));
      expect(flow.minInterests, 3);
      expect(flow.defaultReminderId, 'morning');
      expect(flow.step(OnboardingStepKind.done)!.title, 'You are all set');
    });

    test('every page image is a real file in assets/images', () {
      for (final page in demoFlow().pages) {
        expect(File(page.asset).existsSync(), isTrue, reason: page.asset);
      }
      final int bytes = Directory('assets/images')
          .listSync()
          .whereType<File>()
          .fold<int>(0, (int n, File f) => n + f.lengthSync());
      expect(bytes, lessThan(2 * 1024 * 1024));
    });

    test('the in-memory source serves the content after its latency', () async {
      const InMemoryFlowRemoteDataSource source = InMemoryFlowRemoteDataSource(
        latency: Duration(milliseconds: 5),
      );
      expect(await source.fetchFlow(), InMemoryFlowRemoteDataSource.content);
    });

    test('unknown and repeated steps are ignored and done is last', () {
      final OnboardingFlow flow = FlowMapper.fromJson(<String, Object?>{
        ...InMemoryFlowRemoteDataSource.content,
        'steps': <Object?>[
          <String, Object?>{'kind': 'done', 'title': 'Finished'},
          <String, Object?>{'kind': 'personalise'},
          <String, Object?>{'kind': 'teleport'},
          <String, Object?>{'kind': 'welcome'},
          <String, Object?>{'kind': 'personalise'},
        ],
      });
      expect(flow.steps.map((OnboardingStep s) => s.kind), <OnboardingStepKind>[
        OnboardingStepKind.personalise,
        OnboardingStepKind.welcome,
        OnboardingStepKind.done,
      ]);
      expect(flow.last.title, 'Finished');
    });

    test('a flow with no steps listed uses them all; done is added', () {
      final OnboardingFlow flow = FlowMapper.fromJson(<String, Object?>{
        ...InMemoryFlowRemoteDataSource.content,
        'steps': <Object?>[],
      });
      expect(flow.steps, hasLength(5));
      expect(flow.last.kind, OnboardingStepKind.done);
    });

    test('steps with nothing to show are dropped', () {
      final OnboardingFlow flow = FlowMapper.fromJson(<String, Object?>{
        ...InMemoryFlowRemoteDataSource.content,
        'pages': <Object?>[],
        'permissions': <Object?>[],
      });
      expect(flow.contains(OnboardingStepKind.welcome), isFalse);
      expect(flow.contains(OnboardingStepKind.permissions), isFalse);
      expect(flow.first.kind, OnboardingStepKind.personalise);
    });

    test(
      'permission cards map, including a camera card, and skip unknowns',
      () {
        final OnboardingFlow flow = FlowMapper.fromJson(<String, Object?>{
          ...InMemoryFlowRemoteDataSource.content,
          'permissions': <Object?>[
            <String, Object?>{
              'kind': 'camera',
              'title': 'Camera',
              'benefit': 'Scan things.',
              'optional': false,
            },
            <String, Object?>{
              'kind': 'bluetooth',
              'title': 'x',
              'benefit': 'y',
            },
          ],
        });
        expect(flow.permissions, hasLength(1));
        expect(flow.permissions.single.kind, PermissionKind.camera);
        expect(flow.permissions.single.optional, isFalse);
        expect(flow.permissions.single.deniedHelp, contains('device settings'));
      },
    );

    test('lookups find content by id', () {
      final OnboardingFlow flow = demoFlow();
      expect(flow.interest('music')!.label, 'Music');
      expect(flow.interest('nope'), isNull);
      expect(flow.goal('calm')!.label, 'Feel calmer');
      expect(flow.goal(null), isNull);
      expect(flow.reminder('none')!.label, 'No reminders');
    });
  });

  group('step rules', () {
    final OnboardingFlow flow = demoFlow();

    test('next and previous follow the flow order', () {
      const GetNextStep next = GetNextStep();
      const GetPreviousStep previous = GetPreviousStep();
      expect(
        next(flow, OnboardingStepKind.welcome),
        OnboardingStepKind.permissions,
      );
      expect(next(flow, OnboardingStepKind.done), isNull);
      expect(previous(flow, OnboardingStepKind.welcome), isNull);
      expect(
        previous(flow, OnboardingStepKind.done),
        OnboardingStepKind.account,
      );
    });

    test('next and previous skip steps the flow does not have', () {
      final OnboardingFlow lean = FlowMapper.fromJson(<String, Object?>{
        ...InMemoryFlowRemoteDataSource.content,
        'steps': <Object?>[
          <String, Object?>{'kind': 'welcome'},
          <String, Object?>{'kind': 'account'},
        ],
      });
      expect(
        const GetNextStep()(lean, OnboardingStepKind.welcome),
        OnboardingStepKind.account,
      );
      expect(const GetNextStep()(lean, OnboardingStepKind.personalise), isNull);
    });

    test('personalise is never skippable, whatever the content says', () {
      expect(
        const OnboardingStep(
          kind: OnboardingStepKind.personalise,
          skippable: true,
        ).canSkip,
        isFalse,
      );
      expect(
        const OnboardingStep(kind: OnboardingStepKind.done).canSkip,
        isFalse,
      );
      expect(
        const OnboardingStep(kind: OnboardingStepKind.welcome).canSkip,
        isTrue,
      );
      expect(
        const OnboardingStep(
          kind: OnboardingStepKind.permissions,
          skippable: false,
        ).canSkip,
        isFalse,
      );
      expect(flow.step(OnboardingStepKind.personalise)!.canSkip, isFalse);
    });

    test('only personalise holds the user back, until it is answered', () {
      const CanAdvance canAdvance = CanAdvance();
      const OnboardingProgress empty = OnboardingProgress();
      for (final OnboardingStepKind kind in OnboardingStepKind.values) {
        if (kind == OnboardingStepKind.personalise) continue;
        expect(canAdvance(flow, empty, kind), isTrue, reason: kind.name);
      }
      expect(canAdvance(flow, empty, OnboardingStepKind.personalise), isFalse);
      expect(
        canAdvance(flow, _answered, OnboardingStepKind.personalise),
        isTrue,
      );
      expect(
        canAdvance(
          flow,
          _answered.copyWith(interests: <String>{'focus', 'sleep'}),
          OnboardingStepKind.personalise,
        ),
        isFalse,
        reason: 'two interests are not enough',
      );
      expect(
        canAdvance(
          flow,
          _answered.copyWith(clearGoal: true),
          OnboardingStepKind.personalise,
        ),
        isFalse,
        reason: 'a goal is needed',
      );
      expect(
        canAdvance(
          flow,
          _answered.copyWith(clearReminder: true),
          OnboardingStepKind.personalise,
        ),
        isFalse,
        reason: 'a reminder choice is needed',
      );
    });
  });

  group('ValidateInterests', () {
    const ValidateInterests validate = ValidateInterests();
    final List<Interest> available = demoFlow().interests;

    test('counts against the minimum', () {
      expect(
        validate(selected: <String>{}, available: available, min: 3).isValid,
        isFalse,
      );
      expect(
        validate(
          selected: <String>{'focus', 'sleep', 'music'},
          available: available,
          min: 3,
        ).isValid,
        isTrue,
      );
    });

    test('says how many more are needed', () {
      final one = validate(
        selected: <String>{'focus', 'sleep'},
        available: available,
        min: 3,
      );
      expect(one.missing, 1);
      expect(one.message, 'Pick 1 more to continue.');
      final three = validate(
        selected: <String>{},
        available: available,
        min: 3,
      );
      expect(three.missing, 3);
      expect(three.message, 'Pick 3 more to continue.');
      final ok = validate(
        selected: <String>{'focus', 'sleep', 'music', 'money'},
        available: available,
        min: 3,
      );
      expect(ok.missing, 0);
      expect(ok.message, isNull);
    });

    test('ignores ids the flow no longer offers', () {
      final result = validate(
        selected: <String>{'focus', 'sleep', 'retired-interest'},
        available: available,
        min: 3,
      );
      expect(result.count, 2);
      expect(result.isValid, isFalse);
    });
  });

  group('progress mapping', () {
    test('round-trips every field', () {
      const OnboardingProgress progress = OnboardingProgress(
        step: OnboardingStepKind.account,
        pageIndex: 3,
        section: 2,
        permissions: <PermissionKind, PermissionStatus>{
          PermissionKind.notifications: PermissionStatus.granted,
          PermissionKind.location: PermissionStatus.permanentlyDenied,
        },
        interests: <String>{'focus', 'music'},
        goalId: 'calm',
        reminderId: 'evening',
        accountChoice: AccountChoice.signIn,
        completed: true,
      );
      expect(
        ProgressMapper.fromJson(ProgressMapper.toJson(progress)),
        progress,
      );
    });

    test('the JSON is plain data a store can encode', () {
      final Map<String, Object?> json = ProgressMapper.toJson(_answered);
      expect(json['version'], ProgressMapper.version);
      expect(json['step'], 'personalise');
      expect(json['interests'], <Object?>['focus', 'sleep', 'music']);
    });

    test('unreadable data is treated as no progress', () {
      expect(ProgressMapper.fromJson(<String, Object?>{}), isNull);
      expect(ProgressMapper.fromJson(<String, Object?>{'version': 99}), isNull);
      expect(
        ProgressMapper.fromJson(<String, Object?>{
          'version': ProgressMapper.version,
          'step': 'moon',
        }),
        isNull,
      );
      expect(
        ProgressMapper.fromJson(<String, Object?>{
          'version': ProgressMapper.version,
          'step': 'welcome',
          'interests': 'not a list',
        }),
        isNull,
      );
    });

    test('unknown permissions and statuses are tolerated', () {
      final OnboardingProgress? p = ProgressMapper.fromJson(<String, Object?>{
        'version': ProgressMapper.version,
        'step': 'permissions',
        'permissions': <String, Object?>{
          'bluetooth': 'granted',
          'camera': 'maybe',
        },
      });
      expect(p!.permissions, <PermissionKind, PermissionStatus>{
        PermissionKind.camera: PermissionStatus.notDetermined,
      });
    });
  });

  group('ResumeProgress', () {
    final OnboardingFlow flow = demoFlow();

    Future<OnboardingProgress> resume(
      OnboardingProgress? saved, [
      OnboardingFlow? f,
    ]) async {
      final InMemoryProgressStore store = InMemoryProgressStore(
        saved == null ? null : ProgressMapper.toJson(saved),
      );
      return ResumeProgress(ProgressRepositoryImpl(store))(f ?? flow);
    }

    test(
      'nothing saved starts at the first step with the default reminder',
      () async {
        final OnboardingProgress p = await resume(null);
        expect(p.step, OnboardingStepKind.welcome);
        expect(p.pageIndex, 0);
        expect(p.interests, isEmpty);
        expect(p.reminderId, 'morning');
      },
    );

    test('saved progress comes back as it was', () async {
      final OnboardingProgress p = await resume(
        _answered.copyWith(section: 1, accountChoice: AccountChoice.guest),
      );
      expect(p.step, OnboardingStepKind.personalise);
      expect(p.section, 1);
      expect(p.interests, <String>{'focus', 'sleep', 'music'});
      expect(p.goalId, 'calm');
      expect(p.accountChoice, AccountChoice.guest);
    });

    test('content that changed since is cleaned up', () async {
      final OnboardingFlow smaller = FlowMapper.fromJson(<String, Object?>{
        ...InMemoryFlowRemoteDataSource.content,
        'pages':
            (InMemoryFlowRemoteDataSource.content['pages']! as List<Object?>)
                .take(2)
                .toList(),
        'steps': <Object?>[
          <String, Object?>{'kind': 'welcome'},
          <String, Object?>{'kind': 'personalise'},
        ],
        'permissions':
            (InMemoryFlowRemoteDataSource.content['permissions']!
                    as List<Object?>)
                .take(1)
                .toList(),
      });
      final OnboardingProgress p = await resume(
        const OnboardingProgress(
          step: OnboardingStepKind.account,
          pageIndex: 3,
          section: 9,
          permissions: <PermissionKind, PermissionStatus>{
            PermissionKind.notifications: PermissionStatus.granted,
            PermissionKind.location: PermissionStatus.granted,
          },
          interests: <String>{'focus', 'gone'},
          goalId: 'gone',
          reminderId: 'gone',
        ),
        smaller,
      );
      expect(p.step, OnboardingStepKind.welcome, reason: 'step was removed');
      expect(p.pageIndex, 1, reason: 'only two pages remain');
      expect(p.section, 2);
      expect(p.permissions.keys, <PermissionKind>[
        PermissionKind.notifications,
      ]);
      expect(p.interests, <String>{'focus'});
      expect(p.goalId, isNull);
      expect(p.reminderId, 'morning', reason: 'falls back to the default');
    });

    test('a failing store means a fresh start, not a crash', () async {
      final OnboardingProgress p = await ResumeProgress(_BrokenRepository())(
        flow,
      );
      expect(p.step, OnboardingStepKind.welcome);
    });
  });

  group('SaveProgress and ResetProgress', () {
    test('save writes and reset clears', () async {
      final InMemoryProgressStore store = InMemoryProgressStore();
      final ProgressRepositoryImpl repo = ProgressRepositoryImpl(store);
      await SaveProgress(repo)(_answered);
      expect(await repo.read(), _answered);
      await ResetProgress(repo)();
      expect(await store.read(), isNull);
      expect(await repo.read(), isNull);
    });

    test('a failing store never throws into the flow', () async {
      await SaveProgress(_BrokenRepository())(_answered);
      await ResetProgress(_BrokenRepository())();
    });
  });

  group('CompleteOnboarding', () {
    final OnboardingFlow flow = demoFlow();

    test('refuses until personalise is answered', () async {
      final CompleteOnboarding complete = CompleteOnboarding(
        ProgressRepositoryImpl(InMemoryProgressStore()),
      );
      await expectLater(
        complete(flow, const OnboardingProgress()),
        throwsA(isA<OnboardingIncompleteException>()),
      );
    });

    test(
      'builds the result in flow order, marks completion and saves',
      () async {
        final InMemoryProgressStore store = InMemoryProgressStore();
        final ProgressRepositoryImpl repo = ProgressRepositoryImpl(store);
        final OnboardingResult result = await CompleteOnboarding(repo)(
          flow,
          _answered.copyWith(
            // Chosen "backwards": the result follows the flow's order.
            interests: <String>{'music', 'sleep', 'focus'},
            permissions: const <PermissionKind, PermissionStatus>{
              PermissionKind.notifications: PermissionStatus.granted,
            },
            accountChoice: AccountChoice.createAccount,
          ),
        );
        expect(result.interests, <String>['focus', 'sleep', 'music']);
        expect(result.goalId, 'calm');
        expect(result.reminderId, 'morning');
        expect(result.accountChoice, AccountChoice.createAccount);
        expect(result.permissions, <PermissionKind, PermissionStatus>{
          PermissionKind.notifications: PermissionStatus.granted,
        });
        final OnboardingProgress? saved = await repo.read();
        expect(saved!.completed, isTrue);
        expect(saved.step, OnboardingStepKind.done);
      },
    );

    test('no account choice means guest', () async {
      final OnboardingResult result = await CompleteOnboarding(
        ProgressRepositoryImpl(InMemoryProgressStore()),
      )(flow, _answered);
      expect(result.accountChoice, AccountChoice.guest);
    });

    test('a flow without personalise completes straight away', () async {
      final OnboardingFlow lean = FlowMapper.fromJson(<String, Object?>{
        ...InMemoryFlowRemoteDataSource.content,
        'steps': <Object?>[
          <String, Object?>{'kind': 'welcome'},
        ],
      });
      final OnboardingResult result = await CompleteOnboarding(
        ProgressRepositoryImpl(InMemoryProgressStore()),
      )(lean, const OnboardingProgress());
      expect(result.interests, isEmpty);
    });

    test('a failing store does not block the hand-off', () async {
      final OnboardingResult result = await CompleteOnboarding(
        _BrokenRepository(),
      )(flow, _answered);
      expect(result.goalId, 'calm');
    });
  });

  group('permissions', () {
    test('the demo service grants by default and answers as told', () async {
      final DemoPermissionService service = DemoPermissionService(
        answers: <PermissionKind, PermissionStatus>{
          PermissionKind.camera: PermissionStatus.denied,
        },
      );
      expect(
        await service.status(PermissionKind.camera),
        PermissionStatus.notDetermined,
      );
      expect(
        await service.request(PermissionKind.notifications),
        PermissionStatus.granted,
      );
      expect(
        await service.request(PermissionKind.camera),
        PermissionStatus.denied,
      );
      expect(
        await service.status(PermissionKind.camera),
        PermissionStatus.denied,
      );
    });

    test('RequestPermission returns the answer', () async {
      expect(
        await RequestPermission(DemoPermissionService())(
          PermissionKind.location,
        ),
        PermissionStatus.granted,
      );
    });

    test(
      'RequestPermission turns a failure or no answer into denied',
      () async {
        expect(
          await RequestPermission(_ThrowingService())(PermissionKind.location),
          PermissionStatus.denied,
        );
        expect(
          await RequestPermission(_UndecidedService())(PermissionKind.location),
          PermissionStatus.denied,
        );
      },
    );

    test('OpenPermissionSettings opens them and swallows failures', () async {
      final DemoPermissionService service = DemoPermissionService();
      await OpenPermissionSettings(service)();
      expect(service.settingsOpened, 1);
      await OpenPermissionSettings(_ThrowingService())();
    });

    test('statuses and kinds read back from their keys', () {
      expect(PermissionKind.fromKey('camera'), PermissionKind.camera);
      expect(PermissionKind.fromKey('x'), isNull);
      expect(PermissionStatus.fromKey('granted'), PermissionStatus.granted);
      expect(PermissionStatus.fromKey('x'), PermissionStatus.notDetermined);
      expect(PermissionStatus.denied.isDenied, isTrue);
      expect(PermissionStatus.permanentlyDenied.isDenied, isTrue);
      expect(PermissionStatus.granted.isGranted, isTrue);
      expect(PermissionStatus.notDetermined.isDenied, isFalse);
    });
  });

  group('progress model', () {
    test('copyWith keeps what it is not given and can clear', () {
      final OnboardingProgress next = _answered.copyWith(pageIndex: 2);
      expect(next.interests, _answered.interests);
      expect(next.pageIndex, 2);
      expect(next.copyWith(clearGoal: true).goalId, isNull);
      expect(next.copyWith(clearReminder: true).reminderId, isNull);
      expect(
        next
            .copyWith(accountChoice: AccountChoice.guest)
            .copyWith(clearAccount: true)
            .accountChoice,
        isNull,
      );
    });

    test('statusOf defaults to not determined', () {
      expect(
        const OnboardingProgress().statusOf(PermissionKind.camera),
        PermissionStatus.notDetermined,
      );
    });
  });

  group('utils', () {
    test('joinProse reads naturally', () {
      expect(joinProse(<String>[]), '');
      expect(joinProse(<String>['a']), 'a');
      expect(joinProse(<String>['a', 'b']), 'a and b');
      expect(joinProse(<String>['a', 'b', 'c']), 'a, b and c');
    });
  });
}

class _BrokenRepository implements ProgressRepository {
  @override
  Future<OnboardingProgress?> read() async => throw StateError('disk');

  @override
  Future<void> write(OnboardingProgress progress) async =>
      throw StateError('disk');

  @override
  Future<void> clear() async => throw StateError('disk');
}

class _ThrowingService implements PermissionService {
  @override
  Future<PermissionStatus> status(PermissionKind kind) async =>
      throw StateError('no plugin');

  @override
  Future<PermissionStatus> request(PermissionKind kind) async =>
      throw StateError('no plugin');

  @override
  Future<void> openSettings() async => throw StateError('no plugin');
}

class _UndecidedService implements PermissionService {
  @override
  Future<PermissionStatus> status(PermissionKind kind) async =>
      PermissionStatus.notDetermined;

  @override
  Future<PermissionStatus> request(PermissionKind kind) async =>
      PermissionStatus.notDetermined;

  @override
  Future<void> openSettings() async {}
}
