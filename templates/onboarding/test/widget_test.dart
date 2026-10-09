import 'package:cairn_template_onboarding/cairn_template_onboarding.dart';
import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/onboarding_harness.dart';

/// The whole journey, mounted in the sizes and themes the template is built
/// for. Flutter fails a test on any RenderFlex overflow, so passing at every
/// width also means no overflow.
void main() {
  for (final double width in testWidths) {
    for (final bool dark in <bool>[false, true]) {
      final String where = '${width.toInt()}px ${dark ? 'dark' : 'light'}';
      // A tablet is tall; a small phone is not.
      final double height = width < 400 ? (width == 320 ? 640 : 780) : 1000;

      group(where, () {
        testWidgets('plays the splash, then the first page', (tester) async {
          final Host host = await mountOnboarding(
            tester,
            width: width,
            height: height,
            dark: dark,
            waitForSplash: false,
          );
          expect(find.text('Daybreak'), findsOneWidget);
          expect(find.text('Small habits, steady days.'), findsOneWidget);
          expect(find.text('Start the day on your terms'), findsNothing);
          await playSplash(tester);
          await pumpFrames(tester);
          expect(find.text('Start the day on your terms'), findsOneWidget);
          expect(host.shown, <OnboardingStepKind>[OnboardingStepKind.welcome]);
        });

        testWidgets('plays the whole flow to the callback', (tester) async {
          final Host host = await mountOnboarding(
            tester,
            width: width,
            height: height,
            dark: dark,
          );

          // Value pages.
          expect(page(1), findsOneWidget);
          await tapButton(tester, 'Next');
          expect(find.text('Make room for what matters'), findsOneWidget);
          expect(page(2), findsOneWidget);
          await tapButton(tester, 'Next');
          await tapButton(tester, 'Next');
          expect(find.text('Go further, gently'), findsOneWidget);
          expect(button('Next'), findsNothing);
          await tapButton(tester, 'Get started');

          // Permissions.
          expect(find.text('Stay in the loop'), findsOneWidget);
          await tapOn(tester, buttonNamed('Allow notifications'));
          expect(find.text('Allowed'), findsOneWidget);
          await tapButton(tester, 'Continue');

          // Personalise.
          expect(find.text('What are you into?'), findsOneWidget);
          await pickInterests(tester);
          expect(find.text('What is your main goal?'), findsOneWidget);
          await pickGoalAndReminder(tester);

          // Account, then the summary.
          expect(find.text('Keep your routine safe'), findsOneWidget);
          await tapButton(tester, 'Create account');
          expect(find.text('You are all set'), findsOneWidget);
          expect(find.text('Focus, Fitness and Reading'), findsOneWidget);
          expect(find.text('Feel calmer'), findsOneWidget);
          expect(find.text('Every morning, 8:00'), findsOneWidget);
          expect(find.text('Create an account'), findsOneWidget);

          expect(host.completed, isEmpty);
          await tapButton(tester, 'Start');
          expect(host.completed, hasLength(1));
          final OnboardingResult result = host.completed.single;
          expect(result.interests, <String>['focus', 'fitness', 'reading']);
          expect(result.goalId, 'calm');
          expect(result.reminderId, 'morning');
          expect(result.accountChoice, AccountChoice.createAccount);
          expect(
            result.permissions[PermissionKind.notifications],
            PermissionStatus.granted,
          );
          // A second press does not report twice.
          expect(button('Start'), findsOneWidget);
          await tester.tap(button('Start'));
          await pumpFrames(tester);
          expect(host.completed, hasLength(1));
        });

        testWidgets('every control has a name and a 44px target', (
          tester,
        ) async {
          await mountOnboarding(
            tester,
            width: width,
            height: height,
            dark: dark,
          );
          final SemanticsHandle handle = tester.ensureSemantics();
          expect(find.bySemanticsLabel('Skip this step'), findsOneWidget);
          expect(
            find.bySemanticsLabel(RegExp(r'Onboarding progress, step 1 of 5')),
            findsOneWidget,
          );
          expect(find.bySemanticsLabel('Page 1 of 4'), findsOneWidget);
          for (final Finder f in <Finder>[
            button('Next'),
            buttonNamed('Skip this step'),
          ]) {
            // The tappable area (the target wrapper) is at least 44 tall.
            final Finder target = find.ancestor(
              of: f,
              matching: find.byType(GestureDetector),
            );
            final Size size = tester.getSize(target.first);
            expect(size.height, greaterThanOrEqualTo(44));
          }
          handle.dispose();
        });
      });
    }
  }

  group('welcome', () {
    testWidgets('swiping moves between pages and Skip jumps ahead', (
      tester,
    ) async {
      final Host host = await mountOnboarding(tester);
      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      await pumpFrames(tester);
      expect(find.text('Make room for what matters'), findsOneWidget);
      expect(page(2), findsOneWidget);
      // Swiping back works too.
      await tester.drag(find.byType(PageView), const Offset(300, 0));
      await pumpFrames(tester);
      expect(page(1), findsOneWidget);

      await tapOn(tester, buttonNamed('Skip this step'));
      expect(find.text('Stay in the loop'), findsOneWidget);
      expect(host.skipped, <OnboardingStepKind>[OnboardingStepKind.welcome]);
    });

    testWidgets(
      'the back control and the system back go to the previous page',
      (tester) async {
        await mountOnboarding(tester);
        // Nothing to go back to on the very first page.
        expect(buttonNamed('Back'), findsNothing);
        await tapButton(tester, 'Next');
        expect(page(2), findsOneWidget);
        await tapOn(tester, buttonNamed('Back'));
        expect(page(1), findsOneWidget);

        await tapButton(tester, 'Next');
        await tester.binding.handlePopRoute();
        await pumpFrames(tester);
        expect(page(1), findsOneWidget);
      },
    );
  });

  group('permissions', () {
    testWidgets('allowing shows the result and unlocks nothing it should not', (
      tester,
    ) async {
      final Host host = await mountOnboarding(tester);
      await pastWelcome(tester);
      expect(buttonNamed('Allow notifications'), findsOneWidget);
      expect(buttonNamed('Allow location'), findsOneWidget);
      await tapOn(tester, buttonNamed('Allow location'));
      expect(buttonNamed('Allow location'), findsNothing);
      expect(find.text('Allowed'), findsOneWidget);
      // The other card is untouched.
      expect(buttonNamed('Allow notifications'), findsOneWidget);
      expect(host.completed, isEmpty);
    });

    testWidgets('declining explains how to enable it later and offers retry', (
      tester,
    ) async {
      final DemoPermissionService service = DemoPermissionService(
        answers: <PermissionKind, PermissionStatus>{
          PermissionKind.location: PermissionStatus.denied,
          PermissionKind.notifications: PermissionStatus.permanentlyDenied,
        },
      );
      await mountOnboarding(tester, permissions: service);
      await pastWelcome(tester);

      await tapOn(tester, buttonNamed('Allow location'));
      expect(find.text('Not allowed'), findsOneWidget);
      expect(find.textContaining('then Location'), findsOneWidget);
      expect(buttonNamed('Try allowing location again'), findsOneWidget);
      expect(buttonNamed('Open settings to allow location'), findsOneWidget);

      await tapOn(tester, buttonNamed('Allow notifications'));
      // Permanently declined: no retry, only the settings.
      expect(buttonNamed('Try allowing notifications again'), findsNothing);
      await tapOn(tester, buttonNamed('Open settings to allow notifications'));
      expect(service.settingsOpened, 1);

      // The user can still continue.
      await tapButton(tester, 'Continue');
      expect(find.text('What are you into?'), findsOneWidget);
    });

    testWidgets('Skip passes the step without asking for anything', (
      tester,
    ) async {
      final DemoPermissionService service = DemoPermissionService();
      final Host host = await mountOnboarding(tester, permissions: service);
      await pastWelcome(tester);
      await tapOn(tester, buttonNamed('Skip this step'));
      expect(find.text('What are you into?'), findsOneWidget);
      expect(host.skipped.last, OnboardingStepKind.permissions);
      expect(
        await service.status(PermissionKind.notifications),
        PermissionStatus.notDetermined,
      );
    });
  });

  group('personalise', () {
    Future<Host> toPersonalise(WidgetTester tester) async {
      final Host host = await mountOnboarding(tester);
      await pastWelcome(tester);
      await tapButton(tester, 'Continue');
      return host;
    }

    testWidgets('needs three interests before it moves on', (tester) async {
      await toPersonalise(tester);
      expect(find.text('Pick at least 3. 0 so far.'), findsOneWidget);
      // There is no Skip on this step.
      expect(buttonNamed('Skip this step'), findsNothing);

      await tapChip(tester, 'Focus');
      await tapChip(tester, 'Sleep');
      await tapButton(tester, 'Continue');
      // Still here, and now told what is missing.
      expect(find.text('What are you into?'), findsOneWidget);
      expect(find.text('Pick 1 more to continue.'), findsOneWidget);

      await tapChip(tester, 'Music');
      expect(find.text('Pick 1 more to continue.'), findsNothing);
      expect(find.text('3 picked. Add more if you like.'), findsOneWidget);
      // A chosen chip can be un-chosen.
      await tapChip(tester, 'Music');
      expect(find.text('Pick at least 3. 2 so far.'), findsOneWidget);
    });

    testWidgets('needs a goal, then offers reminders in a select', (
      tester,
    ) async {
      await toPersonalise(tester);
      await pickInterests(tester);
      await tapButton(tester, 'Continue');
      expect(find.text('Choose a goal to continue.'), findsOneWidget);
      expect(find.text('What is your main goal?'), findsOneWidget);

      await pickGoalAndReminderFromGoal(tester);
      expect(find.text('Keep your routine safe'), findsOneWidget);
    });

    testWidgets('the reminder select changes the choice', (tester) async {
      await toPersonalise(tester);
      await pickInterests(tester);
      await tapOn(
        tester,
        find.byWidgetPredicate(
          (Widget w) =>
              w is CairnRadioItem<String> &&
              (w.semanticLabel ?? '').startsWith('Stay focused'),
        ),
      );
      await tapButton(tester, 'Continue');
      expect(find.text('When should we nudge you?'), findsOneWidget);
      expect(find.text('Every morning, 8:00'), findsOneWidget);

      await tapOn(tester, find.byType(CairnSelect<String>));
      await tapOn(tester, find.text('Every evening, 20:00'));
      expect(find.text('Every evening, 20:00'), findsOneWidget);
      await tapButton(tester, 'Continue');
      await tapButton(tester, 'Continue as guest');
      expect(find.text('Every evening, 20:00'), findsOneWidget);
      expect(find.text('Stay focused'), findsOneWidget);
    });

    testWidgets('back steps through the parts before leaving the step', (
      tester,
    ) async {
      await toPersonalise(tester);
      await pickInterests(tester);
      expect(find.text('What is your main goal?'), findsOneWidget);
      await tapOn(tester, buttonNamed('Back'));
      expect(find.text('What are you into?'), findsOneWidget);
      // The answers were kept.
      expect(find.text('3 picked. Add more if you like.'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await pumpFrames(tester);
      expect(find.text('Stay in the loop'), findsOneWidget);
    });
  });

  group('account and done', () {
    testWidgets('sign in and guest are handed to the host', (tester) async {
      for (final (String label, AccountChoice choice)
          in <(String, AccountChoice)>[
            ('I already have an account', AccountChoice.signIn),
            ('Continue as guest', AccountChoice.guest),
          ]) {
        final Host host = await mountOnboarding(tester);
        await pastWelcome(tester);
        await tapButton(tester, 'Continue');
        await pickInterests(tester);
        await pickGoalAndReminder(tester);
        await tapButton(tester, label);
        await tapButton(tester, 'Start');
        expect(host.completed.single.accountChoice, choice);
        await tester.pumpWidget(const SizedBox.shrink());
      }
    });

    testWidgets('Skip on the account step continues as a guest', (
      tester,
    ) async {
      final Host host = await mountOnboarding(tester);
      await pastWelcome(tester);
      await tapButton(tester, 'Continue');
      await pickInterests(tester);
      await pickGoalAndReminder(tester);
      await tapOn(tester, buttonNamed('Skip this step'));
      expect(find.text('Continue as a guest'), findsOneWidget);
      await tapButton(tester, 'Start');
      expect(host.completed.single.accountChoice, AccountChoice.guest);
      expect(host.skipped.last, OnboardingStepKind.account);
    });

    testWidgets('the summary says what was not allowed', (tester) async {
      await mountOnboarding(
        tester,
        permissions: DemoPermissionService(
          answers: <PermissionKind, PermissionStatus>{
            PermissionKind.location: PermissionStatus.denied,
          },
        ),
      );
      await pastWelcome(tester);
      await tapOn(tester, buttonNamed('Allow location'));
      await tapButton(tester, 'Continue');
      await pickInterests(tester);
      await pickGoalAndReminder(tester);
      await tapButton(tester, 'Continue as guest');
      expect(
        find.text('Not allowed. You can change this in settings.'),
        findsOneWidget,
      );
      expect(find.text('Not asked yet'), findsOneWidget);
    });
  });

  group('resume', () {
    testWidgets('re-opening continues where the user left off', (tester) async {
      final Host host = await mountOnboarding(tester);
      await tapButton(tester, 'Next');
      await tapButton(tester, 'Next');
      expect(page(3), findsOneWidget);

      // Simulate the app being closed: unmount, then mount a fresh one on the
      // same store.
      await tester.pumpWidget(const SizedBox.shrink());
      await mountOnboarding(tester, host: host);
      expect(find.text('Better with people'), findsOneWidget);
      expect(page(3), findsOneWidget);
    });

    testWidgets('resumes inside personalise with the answers kept', (
      tester,
    ) async {
      final Host host = await mountOnboarding(tester);
      await pastWelcome(tester);
      await tapButton(tester, 'Continue');
      await pickInterests(tester);
      expect(find.text('What is your main goal?'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await mountOnboarding(tester, host: host);
      expect(find.text('What is your main goal?'), findsOneWidget);
      await tapOn(tester, buttonNamed('Back'));
      expect(find.text('3 picked. Add more if you like.'), findsOneWidget);
    });

    testWidgets('a finished onboarding re-opens on the summary', (
      tester,
    ) async {
      final Host host = await mountOnboarding(tester);
      await playThroughToDone(tester);
      await tapButton(tester, 'Start');
      await tester.pumpWidget(const SizedBox.shrink());

      await mountOnboarding(tester, host: host);
      expect(find.text('You are all set'), findsOneWidget);
      expect(find.text('Focus, Fitness and Reading'), findsOneWidget);
    });

    testWidgets('startAtStep opens a step directly, without the splash', (
      tester,
    ) async {
      await mountOnboarding(tester, startAtStep: OnboardingStepKind.account);
      await pumpFrames(tester);
      expect(find.text('Keep your routine safe'), findsOneWidget);
      expect(find.text('Daybreak'), findsNothing);
    });
  });

  group('integration recipe from the docs', () {
    testWidgets('Start reports choices restored from saved JSON', (
      tester,
    ) async {
      final List<OnboardingResult> done = <OnboardingResult>[];
      final InMemoryProgressStore store = InMemoryProgressStore(
        <String, Object?>{
          'version': 1,
          'step': 'done',
          'pageIndex': 0,
          'section': 2,
          'permissions': <String, Object?>{'notifications': 'granted'},
          'interests': <String>['focus', 'sleep', 'music'],
          'goalId': 'calm',
          'reminderId': 'morning',
          'accountChoice': 'guest',
          'completed': false,
        },
      );
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: CairnTheme.materialTheme(CairnTheme.light),
          home: Scaffold(
            body: OnboardingApp(
              progressStore: store,
              permissionService: DemoPermissionService(),
              startAtStep: OnboardingStepKind.done,
              onCompleted: done.add,
            ),
          ),
        ),
      );
      await pumpFrames(tester, 5);
      await tester.tap(find.widgetWithText(CairnButton, 'Start'));
      await tester.pump();
      expect(done.single.goalId, 'calm');
      expect(
        done.single.permissions[PermissionKind.notifications],
        PermissionStatus.granted,
      );
    });
  });

  group('failure', () {
    testWidgets('a failed load offers a retry', (tester) async {
      final _FlakySource source = _FlakySource();
      await mountOnboarding(tester, flow: source, waitForSplash: false);
      await pumpFrames(tester, 20);
      expect(find.text('We could not load the welcome'), findsOneWidget);
      source.fail = false;
      await tapButton(tester, 'Try again');
      await pumpFrames(tester, 10);
      expect(find.text('Start the day on your terms'), findsOneWidget);
    });
  });

  group('reduced motion', () {
    testWidgets('transitions are instant and the splash is short', (
      tester,
    ) async {
      await mountOnboarding(tester, reducedMotion: true, waitForSplash: false);
      // The mark is fully there from the first frame.
      final Opacity opacity = tester.widget<Opacity>(
        find
            .ancestor(of: find.text('Daybreak'), matching: find.byType(Opacity))
            .first,
      );
      expect(opacity.opacity, 1);
      await pumpFrames(tester, 7);
      expect(find.text('Start the day on your terms'), findsOneWidget);

      // One frame is enough to change page and step.
      await tester.tap(button('Next'));
      await tester.pump();
      await tester.pump();
      expect(find.text('Make room for what matters'), findsOneWidget);
      await tester.tap(button('Next'));
      await tester.pump();
      await tester.tap(button('Next'));
      await tester.pump();
      await tester.tap(button('Get started'));
      await tester.pump();
      await tester.pump();
      expect(find.text('Stay in the loop'), findsOneWidget);
      expect(find.text('Go further, gently'), findsNothing);
    });

    testWidgets('the whole flow works with reduced motion', (tester) async {
      final Host host = await mountOnboarding(tester, reducedMotion: true);
      await playThroughToDone(tester);
      await tapButton(tester, 'Start');
      expect(host.completed, hasLength(1));
    });
  });

  group('large text', () {
    for (final double scale in <double>[1.3, 2.0]) {
      testWidgets('the whole flow fits at ${scale}x on a small phone', (
        tester,
      ) async {
        final Host host = await mountOnboarding(
          tester,
          width: 320,
          height: 640,
          textScale: scale,
        );
        await playThroughToDone(tester);
        await tapButton(tester, 'Start');
        expect(host.completed, hasLength(1));
      });
    }
  });

  group('demo', () {
    testWidgets('Replay is only offered when asked for', (tester) async {
      await mountOnboarding(tester);
      await playThroughToDone(tester);
      expect(find.text('Replay from the start'), findsNothing);
    });

    testWidgets('Replay forgets the progress and starts again', (tester) async {
      final Host host = await mountOnboarding(tester, showReplay: true);
      await playThroughToDone(tester);
      await tapOn(tester, find.text('Replay from the start'));
      expect(find.text('Start the day on your terms'), findsOneWidget);
      expect(page(1), findsOneWidget);
      expect(await host.store.read(), isNull);

      // The restart wiped what was saved: a re-open begins at the start, with
      // nothing chosen.
      await tester.pumpWidget(const SizedBox.shrink());
      await mountOnboarding(tester, host: host);
      expect(page(1), findsOneWidget);
    });
  });
}

Future<void> pickGoalAndReminderFromGoal(WidgetTester tester) async {
  await tapOn(
    tester,
    find.byWidgetPredicate(
      (Widget w) =>
          w is CairnRadioItem<String> &&
          (w.semanticLabel ?? '').startsWith('Build a routine'),
    ),
  );
  await tapButton(tester, 'Continue');
  await tapButton(tester, 'Continue');
}

class _FlakySource implements FlowRemoteDataSource {
  bool fail = true;

  @override
  Future<Map<String, Object?>> fetchFlow() async {
    if (fail) throw StateError('offline');
    return InMemoryFlowRemoteDataSource.content;
  }
}
