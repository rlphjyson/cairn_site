import 'package:cairn_template_onboarding/cairn_template_onboarding.dart';
import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Widths the template is tested at: a small phone, the site's phone frame and
/// a tablet.
const List<double> testWidths = <double>[320, 360, 700];

/// Everything a test needs to see what the host would see.
class Host {
  /// Results handed to `onCompleted`.
  final List<OnboardingResult> completed = <OnboardingResult>[];

  /// Steps reported to `onSkipped`.
  final List<OnboardingStepKind> skipped = <OnboardingStepKind>[];

  /// Steps reported to `onStepChanged`.
  final List<OnboardingStepKind> shown = <OnboardingStepKind>[];

  /// The progress store, shared so a second mount can resume.
  final InMemoryProgressStore store = InMemoryProgressStore();
}

/// Mounts [OnboardingApp] in a `MaterialApp` themed by Cairn, in a viewport of
/// [width] by [height] logical pixels, and plays the splash screen.
///
/// Geist is loaded by `flutter_test_config.dart` when it can be found, so text
/// has real metrics.
Future<Host> mountOnboarding(
  WidgetTester tester, {
  double width = 360,
  double height = 780,
  bool dark = false,
  bool reducedMotion = false,
  Host? host,
  PermissionService? permissions,
  FlowRemoteDataSource? flow,
  OnboardingStepKind? startAtStep,
  bool waitForSplash = true,
  bool showReplay = false,
  double textScale = 1,
}) async {
  final Host h = host ?? Host();
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: CairnTheme.materialTheme(
        (dark ? CairnTheme.dark : CairnTheme.light).copyWith(
          fontFamily: 'Geist',
        ),
      ),
      builder: (BuildContext context, Widget? child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          disableAnimations: reducedMotion,
          textScaler: TextScaler.linear(textScale),
        ),
        child: child!,
      ),
      home: Scaffold(
        body: OnboardingApp(
          onCompleted: h.completed.add,
          onSkipped: h.skipped.add,
          onStepChanged: h.shown.add,
          progressStore: h.store,
          permissionService: permissions,
          flowDataSource: flow,
          startAtStep: startAtStep,
          showReplay: showReplay,
        ),
      ),
    ),
  );
  if (startAtStep == null && waitForSplash) await playSplash(tester);
  if (waitForSplash || startAtStep != null) await pumpFrames(tester);
  return h;
}

/// Lets the splash screen run its fade and hold, then move on.
Future<void> playSplash(WidgetTester tester) => pumpFrames(tester, 20);

/// Pumps [frames] short frames. Never `pumpAndSettle`: Cairn has repeating
/// animations (progress, spinner) that never settle.
Future<void> pumpFrames(WidgetTester tester, [int frames = 6]) async {
  for (int i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// The page indicator reading "Page [n] of [of]".
Finder page(int n, [int of = 4]) => find.byWidgetPredicate(
  (Widget w) => w is Semantics && w.properties.label == 'Page $n of $of',
);

/// The Cairn button with [label].
Finder button(String label) => find.widgetWithText(CairnButton, label);

/// The Cairn button with the accessible name [label].
Finder buttonNamed(String label) => find.byWidgetPredicate(
  (Widget w) => w is CairnButton && w.semanticLabel == label,
);

/// Scrolls [finder] into view, taps it and pumps.
Future<void> tapOn(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder.first);
  await pumpFrames(tester, 2);
  await tester.tap(finder.first);
  await pumpFrames(tester);
}

/// Taps the button labelled [label].
Future<void> tapButton(WidgetTester tester, String label) =>
    tapOn(tester, button(label));

/// The interest chip for [label].
Finder chip(String label) => find.byWidgetPredicate(
  (Widget w) => w is CairnToggle && w.semanticLabel == label,
);

/// Taps the interest chip for [label].
Future<void> tapChip(WidgetTester tester, String label) =>
    tapOn(tester, chip(label));

/// Goes from the welcome pages to the permissions step.
Future<void> pastWelcome(WidgetTester tester) async {
  for (int i = 0; i < 3; i++) {
    await tapButton(tester, 'Next');
  }
  await tapButton(tester, 'Get started');
}

/// Picks three interests, then moves to the goal part.
Future<void> pickInterests(
  WidgetTester tester, [
  List<String> labels = const <String>['Focus', 'Fitness', 'Reading'],
]) async {
  for (final String label in labels) {
    await tapChip(tester, label);
  }
  await tapButton(tester, 'Continue');
}

/// Chooses [goal], moves on, keeps the default reminder and moves on.
Future<void> pickGoalAndReminder(
  WidgetTester tester, [
  String goal = 'Feel calmer',
]) async {
  await tapOn(
    tester,
    find.byWidgetPredicate(
      (Widget w) =>
          w is CairnRadioItem<String> &&
          (w.semanticLabel ?? '').startsWith(goal),
    ),
  );
  await tapButton(tester, 'Continue');
  await tapButton(tester, 'Continue');
}

/// Plays the flow from the welcome pages to the done screen, as a guest.
Future<void> playThroughToDone(WidgetTester tester) async {
  await pastWelcome(tester);
  await tapButton(tester, 'Continue');
  await pickInterests(tester);
  await pickGoalAndReminder(tester);
  await tapButton(tester, 'Continue as guest');
}
