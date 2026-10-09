import 'package:cairn_template_auth/cairn_template_auth.dart';
import 'package:cairn_template_auth/core/presentation/navigation/auth_navigation_cubit.dart';
import 'package:cairn_template_auth/presentation/shell/auth_shell.dart';
import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

/// Widths the template is tested at: a small phone, the site's phone frame and
/// a tablet.
const List<double> testWidths = <double>[320, 360, 700];

/// Heights that go with [testWidths].
double heightFor(double width) =>
    width >= 700 ? 900 : (width <= 320 ? 640 : 780);

/// Mounts [AuthApp] in a `MaterialApp` themed by Cairn, in a viewport of
/// [width] by [height] logical pixels.
///
/// The in-memory server answers with no latency so tests need only a few
/// frames per step. Geist is loaded by `flutter_test_config.dart`.
Future<void> mountAuth(
  WidgetTester tester, {
  double width = 360,
  double? height,
  bool dark = false,
  AuthApp Function(AuthApp app)? configure,
  AuthRemoteDataSource? dataSource,
  AuthScreen startOn = AuthScreen.welcome,
  void Function(Session session)? onAuthenticated,
  VoidCallback? onSignedOut,
  SocialIdTokenProvider? onSocialSignIn,
  void Function(AuthLegalLink link)? onLegalLink,
  bool showDemoHint = false,
  String? resetToken,
  bool recoveryByLink = false,
}) async {
  tester.view.physicalSize = Size(width, height ?? heightFor(width));
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final CairnTheme theme = (dark ? CairnTheme.dark : CairnTheme.light).copyWith(
    fontFamily: 'Geist',
  );
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: CairnTheme.materialTheme(theme),
      home: Scaffold(
        body: AuthApp(
          authDataSource:
              dataSource ??
              InMemoryAuthRemoteDataSource(latency: Duration.zero),
          startOn: startOn,
          onAuthenticated: onAuthenticated,
          onSignedOut: onSignedOut,
          onSocialSignIn: onSocialSignIn,
          onLegalLink: onLegalLink,
          showDemoHint: showDemoHint,
          resetToken: resetToken,
          recoveryByLink: recoveryByLink,
        ),
      ),
    ),
  );
  await pumpFrames(tester);
}

/// Pumps [frames] short frames. Never `pumpAndSettle`: Cairn has repeating
/// animations (spinner, progress) that never settle.
Future<void> pumpFrames(WidgetTester tester, [int frames = 6]) async {
  for (int i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Removes the app so its timers and cubits are disposed before the test ends.
Future<void> unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 100));
}

/// Reads a session cubit from the mounted app.
T read<T extends StateStreamableSource<Object?>>(WidgetTester tester) =>
    tester.element(find.byType(AuthShell)).read<T>();

/// The text field inside the field titled [label] (matched by its semantic
/// label, which is the label with any error appended).
Finder field(String label) => find.byWidgetPredicate(
  (Widget w) => w is CairnInput && (w.semanticLabel ?? '').startsWith(label),
);

/// The editable text of [field].
Finder editable(String label) =>
    find.descendant(of: field(label), matching: find.byType(EditableText));

/// Scrolls [finder] into view in the current screen, then pumps.
Future<void> reveal(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder.first);
  await pumpFrames(tester, 2);
}

/// Types [text] into the field titled [label].
Future<void> fill(WidgetTester tester, String label, String text) async {
  await reveal(tester, editable(label));
  await tester.enterText(editable(label), text);
  await pumpFrames(tester, 2);
}

/// Scrolls to the first widget showing [text], taps it and pumps.
Future<void> tapText(WidgetTester tester, String text) async {
  await reveal(tester, find.text(text));
  await tester.tap(find.text(text).first);
  await pumpFrames(tester);
}

/// Types a code into the one-time-code field.
Future<void> enterCode(WidgetTester tester, String code) async {
  final Finder input = find.descendant(
    of: find.byType(CairnInputOtp),
    matching: find.byType(EditableText),
  );
  await tester.enterText(input, code);
  await pumpFrames(tester);
}

/// The current screen on the navigation stack.
AuthScreen currentScreen(WidgetTester tester) =>
    read<AuthNavigationCubit>(tester).state.top.screen;
