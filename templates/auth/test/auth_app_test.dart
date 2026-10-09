import 'package:cairn_template_auth/cairn_template_auth.dart';
import 'package:cairn_template_auth/core/presentation/widgets/labeled_input.dart';
import 'package:cairn_template_auth/core/presentation/widgets/touch_target.dart';
import 'package:cairn_template_auth/presentation/shell/auth_shell.dart';
import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/auth_harness.dart';
import 'support/fakes.dart';

/// A server that cannot be reached.
class _OfflineDataSource extends InMemoryAuthRemoteDataSource {
  _OfflineDataSource() : super(latency: Duration.zero);

  @override
  Future<Map<String, Object?>> signIn({
    required String email,
    required String password,
    required bool remember,
  }) async => throw Exception('socket closed');
}

/// A server whose reset sessions have always expired.
class _ExpiringDataSource extends InMemoryAuthRemoteDataSource {
  _ExpiringDataSource() : super(latency: Duration.zero);

  @override
  Future<Map<String, Object?>> resetPassword({
    required String resetToken,
    required String password,
  }) async => <String, Object?>{
    'error': <String, Object?>{'code': 'code_expired'},
  };
}

const String ada = 'ada@example.com';
const String adaPassword = 'Cairn-demo-1';

/// Asserts nothing threw (an overflow is reported as an exception).
void noErrors(WidgetTester tester) => expect(tester.takeException(), isNull);

Finder get backButton => find.bySemanticsLabel('Back');

Future<void> toggleTerms(WidgetTester tester) async {
  await reveal(tester, find.byType(CairnCheckbox));
  await tester.tap(find.byType(CairnCheckbox));
  await pumpFrames(tester, 2);
}

/// The text a field currently holds.
String valueOf(WidgetTester tester, String label) =>
    tester.widget<EditableText>(editable(label)).controller.text;

/// Walks every flow once: sign in wrong then right, sign out, forgot password
/// through verify (wrong then right) and reset, sign in with the new password,
/// sign up, sign out.
Future<void> journey(
  WidgetTester tester, {
  required List<Session> signedIn,
  required List<String> signedOut,
}) async {
  // Welcome.
  expect(find.text('Cairn'), findsOneWidget);
  expect(find.text('Continue with Google'), findsOneWidget);
  expect(find.text('Continue with Apple'), findsOneWidget);
  expect(find.text('Sign in with email'), findsOneWidget);
  expect(find.text('Create an account'), findsOneWidget);
  expect(find.text('Terms'), findsOneWidget);
  expect(find.text('Privacy Policy'), findsOneWidget);
  noErrors(tester);

  // Sign in: wrong, then right.
  await tapText(tester, 'Sign in with email');
  expect(find.text('Welcome back'), findsOneWidget);
  noErrors(tester);
  await fill(tester, 'Email', ada);
  await fill(tester, 'Password', 'not-the-password');
  await tapText(tester, 'Sign in');
  expect(find.text('Could not sign you in'), findsOneWidget);
  expect(find.textContaining('email or password is not right'), findsOneWidget);
  noErrors(tester);
  await fill(tester, 'Password', adaPassword);
  expect(
    find.text('Could not sign you in'),
    findsNothing,
    reason: 'typing dismisses the alert',
  );
  await tapText(tester, 'Sign in');
  expect(find.text('Welcome, Ada'), findsOneWidget);
  expect(find.text('AL'), findsOneWidget);
  expect(find.text(ada), findsOneWidget);
  expect(currentScreen(tester), AuthScreen.signedIn);
  expect(signedIn.map((Session s) => s.account.email), <String>[ada]);
  noErrors(tester);

  // Sign out.
  await tapText(tester, 'Sign out');
  expect(currentScreen(tester), AuthScreen.welcome);
  expect(find.text('Sign in with email'), findsOneWidget);
  expect(signedOut, hasLength(1));
  noErrors(tester);

  // Forgot password: request, wrong code, right code, reset.
  await tapText(tester, 'Sign in with email');
  await tapText(tester, 'Forgot password?');
  expect(find.text('Forgot your password?'), findsOneWidget);
  await fill(tester, 'Email', ada);
  await tapText(tester, 'Send code');
  expect(find.text('Check your inbox'), findsOneWidget);
  expect(find.textContaining('If an account exists for $ada'), findsOneWidget);
  noErrors(tester);
  await tapText(tester, 'Enter code');
  expect(find.text('Enter the code'), findsOneWidget);
  expect(find.textContaining(ada), findsWidgets);
  await enterCode(tester, '000000');
  expect(find.text('Wrong code'), findsOneWidget);
  expect(find.text('That code is not right. 4 attempts left.'), findsOneWidget);
  noErrors(tester);
  await enterCode(tester, '123456');
  expect(find.text('Choose a new password'), findsOneWidget);
  expect(currentScreen(tester), AuthScreen.resetPassword);
  await fill(tester, 'Password', 'Brand-new-2');
  expect(find.text('Strong'), findsOneWidget);
  await fill(tester, 'Confirm password', 'Brand-new-2');
  await tapText(tester, 'Update password');
  expect(find.text('Password updated'), findsOneWidget);
  expect(
    backButton,
    findsNothing,
    reason: 'there is nothing to go back to after a reset',
  );
  noErrors(tester);

  // Back to sign in with the new password.
  await tapText(tester, 'Continue to sign in');
  expect(find.text('Welcome back'), findsOneWidget);
  expect(valueOf(tester, 'Email'), ada, reason: 'the email is prefilled');
  await fill(tester, 'Password', adaPassword);
  await tapText(tester, 'Sign in');
  expect(
    find.text('Could not sign you in'),
    findsOneWidget,
    reason: 'the old password is dead',
  );
  await fill(tester, 'Password', 'Brand-new-2');
  await tapText(tester, 'Sign in');
  expect(find.text('Welcome, Ada'), findsOneWidget);
  await tapText(tester, 'Sign out');
  expect(signedOut, hasLength(2));
  noErrors(tester);

  // Sign up.
  await tapText(tester, 'Create an account');
  expect(find.text('Create your account'), findsOneWidget);
  await fill(tester, 'Full name', 'Grace Hopper');
  await fill(tester, 'Email', 'grace@example.com');
  await fill(tester, 'Password', 'abc');
  expect(find.text('Too short'), findsOneWidget);
  await fill(tester, 'Password', 'Compile-r-1');
  expect(find.text('Strong'), findsOneWidget);
  await fill(tester, 'Confirm password', 'Compile-r-1');
  await toggleTerms(tester);
  await tapText(tester, 'Create account');
  expect(find.text('Welcome, Grace'), findsOneWidget);
  expect(find.text('GH'), findsOneWidget);
  expect(signedIn.map((Session s) => s.account.email), <String>[
    ada,
    ada,
    'grace@example.com',
  ]);
  noErrors(tester);
  await tapText(tester, 'Sign out');
  expect(find.text('Sign in with email'), findsOneWidget);
  expect(signedOut, hasLength(3));
  noErrors(tester);
}

void main() {
  group('the whole journey', () {
    for (final double width in testWidths) {
      for (final bool dark in <bool>[false, true]) {
        testWidgets('${width.toInt()} px wide, ${dark ? 'dark' : 'light'}', (
          WidgetTester tester,
        ) async {
          final List<Session> signedIn = <Session>[];
          final List<String> signedOut = <String>[];
          await mountAuth(
            tester,
            width: width,
            dark: dark,
            onAuthenticated: signedIn.add,
            onSignedOut: () => signedOut.add('out'),
          );
          expect(tester.getSize(find.byType(AuthShell)).width, width);
          await journey(tester, signedIn: signedIn, signedOut: signedOut);
          await unmount(tester);
        });
      }
    }
  });

  group('welcome', () {
    testWidgets('has no back button and leads to sign in and sign up', (
      WidgetTester tester,
    ) async {
      await mountAuth(tester);
      expect(backButton, findsNothing);
      await tapText(tester, 'Create an account');
      expect(find.text('Create your account'), findsOneWidget);
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await pumpFrames(tester);
      expect(find.text('Continue with Google'), findsOneWidget);
      noErrors(tester);
      await unmount(tester);
    });

    testWidgets('the legal links call the host', (WidgetTester tester) async {
      final List<AuthLegalLink> opened = <AuthLegalLink>[];
      await mountAuth(tester, onLegalLink: opened.add);
      await tester.tap(find.text('Terms'));
      await tester.tap(find.text('Privacy Policy'));
      expect(opened, <AuthLegalLink>[
        AuthLegalLink.terms,
        AuthLegalLink.privacy,
      ]);
      await unmount(tester);
    });

    testWidgets(
      'Continue with Google signs in with the token the host provides',
      (WidgetTester tester) async {
        final List<Session> signedIn = <Session>[];
        final List<SocialProvider> asked = <SocialProvider>[];
        await mountAuth(
          tester,
          onAuthenticated: signedIn.add,
          onSocialSignIn: (SocialProvider p) async {
            asked.add(p);
            return 'real-token';
          },
        );
        await tapText(tester, 'Continue with Google');
        expect(asked, <SocialProvider>[SocialProvider.google]);
        expect(signedIn.single.account.id, 'social-google');
        expect(find.textContaining('Welcome, Taylor'), findsOneWidget);
        await unmount(tester);
      },
    );

    testWidgets('a cancelled provider sheet stays on the welcome screen', (
      WidgetTester tester,
    ) async {
      await mountAuth(tester, onSocialSignIn: (SocialProvider p) async => null);
      await tapText(tester, 'Continue with Apple');
      expect(find.text('Continue with Apple'), findsOneWidget);
      expect(find.textContaining('Something went wrong'), findsNothing);
      expect(currentScreen(tester), AuthScreen.welcome);
      await unmount(tester);
    });

    testWidgets('a failing provider SDK shows an offline alert', (
      WidgetTester tester,
    ) async {
      await mountAuth(
        tester,
        onSocialSignIn: (SocialProvider p) async =>
            throw StateError('no network'),
      );
      await tapText(tester, 'Continue with Google');
      expect(find.text('You seem to be offline'), findsOneWidget);
      noErrors(tester);
      await unmount(tester);
    });

    testWidgets('the providers can be chosen, or hidden', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      Future<void> mountWith(List<SocialProvider> providers) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: CairnTheme.materialTheme(
              CairnTheme.light.copyWith(fontFamily: 'Geist'),
            ),
            home: Scaffold(
              body: AuthApp(
                authDataSource: InMemoryAuthRemoteDataSource(
                  latency: Duration.zero,
                ),
                socialProviders: providers,
              ),
            ),
          ),
        );
        await pumpFrames(tester);
      }

      await mountWith(<SocialProvider>[SocialProvider.apple]);
      expect(find.text('Continue with Apple'), findsOneWidget);
      expect(find.text('Continue with Google'), findsNothing);
      await unmount(tester);

      await mountWith(const <SocialProvider>[]);
      expect(find.text('Continue with Apple'), findsNothing);
      expect(find.text('or'), findsNothing);
      expect(find.text('Sign in with email'), findsOneWidget);
      await unmount(tester);
    });
  });

  group('sign in', () {
    testWidgets('asks for both fields', (WidgetTester tester) async {
      await mountAuth(tester, startOn: AuthScreen.signIn);
      await tapText(tester, 'Sign in');
      expect(find.text('Enter your email address.'), findsOneWidget);
      expect(find.text('Enter your password.'), findsOneWidget);
      noErrors(tester);
      await unmount(tester);
    });

    testWidgets('checks the email when the field is left', (
      WidgetTester tester,
    ) async {
      await mountAuth(tester, startOn: AuthScreen.signIn);
      await fill(tester, 'Email', 'nope');
      expect(find.text('Enter a valid email address.'), findsNothing);
      await tester.tap(editable('Password'));
      await pumpFrames(tester, 2);
      expect(find.text('Enter a valid email address.'), findsOneWidget);
      await fill(tester, 'Email', 'nope@example.com');
      expect(find.text('Enter a valid email address.'), findsNothing);
      await unmount(tester);
    });

    testWidgets('shows and hides the password', (WidgetTester tester) async {
      await mountAuth(tester, startOn: AuthScreen.signIn);
      expect(
        tester.widget<EditableText>(editable('Password')).obscureText,
        isTrue,
      );
      await tester.tap(find.bySemanticsLabel('Show password'));
      await pumpFrames(tester, 2);
      expect(
        tester.widget<EditableText>(editable('Password')).obscureText,
        isFalse,
      );
      expect(find.bySemanticsLabel('Hide password'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Hide password'));
      await pumpFrames(tester, 2);
      expect(
        tester.widget<EditableText>(editable('Password')).obscureText,
        isTrue,
      );
      await unmount(tester);
    });

    testWidgets('remember me reaches the session', (WidgetTester tester) async {
      final List<Session> signedIn = <Session>[];
      await mountAuth(
        tester,
        startOn: AuthScreen.signIn,
        onAuthenticated: signedIn.add,
      );
      await tester.tap(find.text('Remember me'));
      await pumpFrames(tester, 2);
      await fill(tester, 'Email', ada);
      await fill(tester, 'Password', adaPassword);
      await tapText(tester, 'Sign in');
      expect(signedIn.single.remembered, isTrue);
      await unmount(tester);
    });

    testWidgets('five wrong passwords lock it, with a finite text countdown', (
      WidgetTester tester,
    ) async {
      final FakeClock clock = FakeClock();
      await mountAuth(
        tester,
        startOn: AuthScreen.signIn,
        dataSource: InMemoryAuthRemoteDataSource(
          latency: Duration.zero,
          clock: clock.call,
        ),
      );
      await fill(tester, 'Email', ada);
      await fill(tester, 'Password', 'wrong-one');
      for (int i = 0; i < 4; i++) {
        await tapText(tester, 'Sign in');
        expect(find.text('Could not sign you in'), findsOneWidget);
      }
      await tapText(tester, 'Sign in');
      expect(find.text('Too many attempts'), findsOneWidget);
      expect(find.text('Try again in 30s'), findsOneWidget);
      expect(find.text('Sign in'), findsNothing);
      noErrors(tester);

      // Tapping the locked button does nothing.
      await tester.tap(find.text('Try again in 30s'), warnIfMissed: false);
      await pumpFrames(tester, 2);
      expect(find.text('Too many attempts'), findsOneWidget);

      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      expect(find.text('Try again in 25s'), findsOneWidget);

      for (int i = 0; i < 25; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      clock.advance(const Duration(seconds: 30));
      await pumpFrames(tester, 2);
      expect(find.text('Too many attempts'), findsNothing);
      expect(find.text('Sign in'), findsOneWidget);

      await fill(tester, 'Password', adaPassword);
      await tapText(tester, 'Sign in');
      expect(find.text('Welcome, Ada'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('an unreachable server shows an offline alert', (
      WidgetTester tester,
    ) async {
      await mountAuth(
        tester,
        startOn: AuthScreen.signIn,
        dataSource: _OfflineDataSource(),
      );
      await fill(tester, 'Email', ada);
      await fill(tester, 'Password', adaPassword);
      await tapText(tester, 'Sign in');
      expect(find.text('You seem to be offline'), findsOneWidget);
      expect(find.textContaining('could not reach the server'), findsOneWidget);
      noErrors(tester);
      await unmount(tester);
    });

    testWidgets('the demo hint appears only when asked for', (
      WidgetTester tester,
    ) async {
      await mountAuth(tester, startOn: AuthScreen.signIn);
      expect(find.textContaining('Demo account'), findsNothing);
      await unmount(tester);
      await mountAuth(tester, startOn: AuthScreen.signIn, showDemoHint: true);
      expect(find.textContaining('Demo account'), findsOneWidget);
      expect(find.textContaining(adaPassword), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('what was typed survives a trip to another screen', (
      WidgetTester tester,
    ) async {
      await mountAuth(tester);
      await tapText(tester, 'Sign in with email');
      await fill(tester, 'Email', 'kept@example.com');
      await tapText(tester, 'Create one');
      expect(find.text('Create your account'), findsOneWidget);
      await tapText(tester, 'Sign in');
      expect(find.text('Welcome back'), findsOneWidget);
      expect(valueOf(tester, 'Email'), 'kept@example.com');
      await unmount(tester);
    });
  });

  group('sign up', () {
    testWidgets('reports every problem, with the terms last', (
      WidgetTester tester,
    ) async {
      await mountAuth(tester, startOn: AuthScreen.signUp);
      await fill(tester, 'Full name', 'A');
      await fill(tester, 'Email', 'nope');
      await fill(tester, 'Password', 'abc');
      await fill(tester, 'Confirm password', 'abd');
      await tapText(tester, 'Create account');
      expect(find.text('Your name is too short.'), findsOneWidget);
      expect(find.text('Enter a valid email address.'), findsOneWidget);
      expect(find.text('Use at least 8 characters.'), findsOneWidget);
      expect(find.text('The passwords do not match.'), findsOneWidget);
      expect(
        find.text('Accept the terms to create your account.'),
        findsOneWidget,
      );
      noErrors(tester);
      await toggleTerms(tester);
      expect(
        find.text('Accept the terms to create your account.'),
        findsNothing,
      );
      await unmount(tester);
    });

    testWidgets('the strength meter and the checklist follow the password', (
      WidgetTester tester,
    ) async {
      await mountAuth(tester, startOn: AuthScreen.signUp);
      expect(find.text('Choose a strong password'), findsOneWidget);

      double value() =>
          tester.widget<CairnProgress>(find.byType(CairnProgress)).value!;
      expect(value(), 0);

      await fill(tester, 'Password', 'abc');
      expect(find.text('Too short'), findsOneWidget);
      final double tooShort = value();
      expect(tooShort, inExclusiveRange(0, 0.25));

      await fill(tester, 'Password', 'abcdefgh');
      expect(find.text('Weak'), findsOneWidget);
      final double weak = value();
      expect(weak, greaterThan(tooShort));

      await fill(tester, 'Password', 'Abcdefg1');
      expect(find.text('Fair'), findsOneWidget);
      final double fair = value();
      expect(fair, greaterThan(weak));

      await fill(tester, 'Password', 'Cairn-demo-1');
      expect(find.text('Strong'), findsOneWidget);
      expect(value(), greaterThan(fair));

      // The checklist: each line is spoken with whether it is met.
      final SemanticsHandle handle = tester.ensureSemantics();
      expect(
        find.bySemanticsLabel('At least 8 characters, met'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('A symbol (recommended), met'),
        findsOneWidget,
      );
      await fill(tester, 'Password', 'abcdefgh');
      expect(find.bySemanticsLabel('A number, not met'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Upper and lower case letters, not met'),
        findsOneWidget,
      );
      handle.dispose();
      await unmount(tester);
    });

    testWidgets(
      'an email that is already registered is reported on the field',
      (WidgetTester tester) async {
        await mountAuth(tester, startOn: AuthScreen.signUp);
        await fill(tester, 'Full name', 'Ada Again');
        await fill(tester, 'Email', ada);
        await fill(tester, 'Password', 'Abcdefg1');
        await fill(tester, 'Confirm password', 'Abcdefg1');
        await toggleTerms(tester);
        await tapText(tester, 'Create account');
        expect(
          find.text(
            'An account with this email already exists. Try signing in.',
          ),
          findsOneWidget,
        );
        expect(currentScreen(tester), AuthScreen.signUp);
        // Editing the email clears it.
        await fill(tester, 'Email', 'someone.else@example.com');
        expect(find.textContaining('already exists'), findsNothing);
        noErrors(tester);
        await unmount(tester);
      },
    );

    testWidgets('the passwords are cleared when the account is created', (
      WidgetTester tester,
    ) async {
      final List<Session> signedIn = <Session>[];
      await mountAuth(
        tester,
        startOn: AuthScreen.signUp,
        onAuthenticated: signedIn.add,
      );
      await fill(tester, 'Full name', 'Grace Hopper');
      await fill(tester, 'Email', 'grace@example.com');
      await fill(tester, 'Password', 'Compile-r-1');
      await fill(tester, 'Confirm password', 'Compile-r-1');
      final TextEditingController password = tester
          .widget<EditableText>(editable('Password'))
          .controller;
      await toggleTerms(tester);
      await tapText(tester, 'Create account');
      expect(signedIn, hasLength(1));
      expect(password.text, isEmpty);
      await unmount(tester);
    });
  });

  group('forgot password', () {
    testWidgets('asks for a valid email', (WidgetTester tester) async {
      await mountAuth(tester, startOn: AuthScreen.forgotPassword);
      await tapText(tester, 'Send code');
      expect(find.text('Enter your email address.'), findsOneWidget);
      await fill(tester, 'Email', 'nope');
      await tapText(tester, 'Send code');
      expect(find.text('Enter a valid email address.'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('answers the same for an address that has no account', (
      WidgetTester tester,
    ) async {
      await mountAuth(tester, startOn: AuthScreen.forgotPassword);
      await fill(tester, 'Email', 'nobody@example.com');
      await tapText(tester, 'Send code');
      expect(find.text('Check your inbox'), findsOneWidget);
      expect(
        find.textContaining('If an account exists for nobody@example.com'),
        findsOneWidget,
      );
      expect(find.textContaining('not found'), findsNothing);
      await tapText(tester, 'Enter code');
      await enterCode(tester, '123456');
      expect(find.text('Choose a new password'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('can go back to the form or to sign in', (
      WidgetTester tester,
    ) async {
      await mountAuth(tester, startOn: AuthScreen.forgotPassword);
      await fill(tester, 'Email', ada);
      await tapText(tester, 'Send code');
      await tapText(tester, 'Use a different email');
      expect(find.text('Forgot your password?'), findsOneWidget);
      expect(valueOf(tester, 'Email'), ada);
      await tapText(tester, 'Send code');
      await tapText(tester, 'Back to sign in');
      expect(find.text('Welcome back'), findsOneWidget);
      await unmount(tester);
    });
  });

  group('verify code', () {
    Future<void> openVerify(WidgetTester tester, {FakeClock? clock}) async {
      await mountAuth(
        tester,
        startOn: AuthScreen.forgotPassword,
        dataSource: clock == null
            ? null
            : InMemoryAuthRemoteDataSource(
                latency: Duration.zero,
                clock: clock.call,
              ),
        showDemoHint: true,
      );
      await fill(tester, 'Email', ada);
      await tapText(tester, 'Send code');
      await tapText(tester, 'Enter code');
      expect(find.text('Enter the code'), findsOneWidget);
    }

    testWidgets(
      'the button waits for six digits and the field submits itself',
      (WidgetTester tester) async {
        await openVerify(tester);
        expect(find.textContaining('Demo code: 123456'), findsOneWidget);
        CairnButton verifyButton() => tester.widget<CairnButton>(
          find.ancestor(
            of: find.text('Verify code'),
            matching: find.byType(CairnButton),
          ),
        );
        expect(verifyButton().onPressed, isNull);
        await enterCode(tester, '12345');
        expect(verifyButton().onPressed, isNull);
        await enterCode(tester, '123456');
        expect(find.text('Choose a new password'), findsOneWidget);
        noErrors(tester);
        await unmount(tester);
      },
    );

    testWidgets(
      'the resend link appears after a finite countdown, then restarts it',
      (WidgetTester tester) async {
        await openVerify(tester);
        expect(find.text('Resend code in 0:30'), findsOneWidget);
        expect(find.text('Resend code'), findsNothing);
        for (int i = 0; i < 5; i++) {
          await tester.pump(const Duration(seconds: 1));
        }
        expect(find.text('Resend code in 0:25'), findsOneWidget);
        for (int i = 0; i < 25; i++) {
          await tester.pump(const Duration(seconds: 1));
        }
        expect(find.text('Resend code'), findsOneWidget);
        expect(find.textContaining('Resend code in'), findsNothing);

        await tapText(tester, 'Resend code');
        expect(find.text('We sent a new code to $ada.'), findsOneWidget);
        expect(find.text('Resend code in 0:30'), findsOneWidget);
        noErrors(tester);
        await unmount(tester);
      },
    );

    testWidgets('five wrong codes lock it until a new code is requested', (
      WidgetTester tester,
    ) async {
      await openVerify(tester);
      await enterCode(tester, '111111');
      expect(
        find.text('That code is not right. 4 attempts left.'),
        findsOneWidget,
      );
      await enterCode(tester, '222222');
      expect(
        find.text('That code is not right. 3 attempts left.'),
        findsOneWidget,
      );
      await enterCode(tester, '333333');
      await enterCode(tester, '444444');
      expect(
        find.text('That code is not right. 1 attempt left.'),
        findsOneWidget,
      );
      await enterCode(tester, '555555');
      expect(find.text('Too many wrong codes'), findsOneWidget);
      expect(
        find.text('Too many wrong codes. Request a new code to continue.'),
        findsOneWidget,
      );
      expect(
        tester.widget<CairnInputOtp>(find.byType(CairnInputOtp)).enabled,
        isFalse,
      );

      for (int i = 0; i < 30; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
      await tapText(tester, 'Resend code');
      expect(find.text('Too many wrong codes'), findsNothing);
      expect(
        tester.widget<CairnInputOtp>(find.byType(CairnInputOtp)).enabled,
        isTrue,
      );
      await enterCode(tester, '123456');
      expect(find.text('Choose a new password'), findsOneWidget);
      noErrors(tester);
      await unmount(tester);
    });

    testWidgets('an expired code asks for a new one', (
      WidgetTester tester,
    ) async {
      final FakeClock clock = FakeClock();
      await openVerify(tester, clock: clock);
      clock.advance(const Duration(minutes: 11));
      await enterCode(tester, '123456');
      expect(find.text('Code expired'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('the Paste button takes the digits from the clipboard', (
      WidgetTester tester,
    ) async {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall call) async => call.method == 'Clipboard.getData'
            ? <String, Object?>{
                'text': 'Your code is 123 456. Do not share it.',
              }
            : null,
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await openVerify(tester);
      await tapText(tester, 'Paste code');
      expect(find.text('Choose a new password'), findsOneWidget);
      noErrors(tester);
      await unmount(tester);
    });

    testWidgets('pasted text with too many digits is cut to six', (
      WidgetTester tester,
    ) async {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall call) async => call.method == 'Clipboard.getData'
            ? <String, Object?>{'text': '9999999'}
            : null,
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await openVerify(tester);
      await tapText(tester, 'Paste code');
      expect(
        find.text('That code is not right. 4 attempts left.'),
        findsOneWidget,
      );
      await unmount(tester);
    });

    testWidgets('leaving the screen mid-countdown leaves no timer behind', (
      WidgetTester tester,
    ) async {
      await openVerify(tester);
      await tester.pump(const Duration(seconds: 3));
      await unmount(tester);
      // flutter_test fails a test that ends with a pending timer.
    });
  });

  group('reset password', () {
    Future<void> openReset(
      WidgetTester tester, {
      AuthRemoteDataSource? dataSource,
    }) async {
      await mountAuth(
        tester,
        startOn: AuthScreen.forgotPassword,
        dataSource: dataSource,
      );
      await fill(tester, 'Email', ada);
      await tapText(tester, 'Send code');
      await tapText(tester, 'Enter code');
      await enterCode(tester, '123456');
      expect(find.text('Choose a new password'), findsOneWidget);
    }

    testWidgets('checks the password and the confirmation', (
      WidgetTester tester,
    ) async {
      await openReset(tester);
      await tapText(tester, 'Update password');
      expect(find.text('Enter your password.'), findsOneWidget);
      await fill(tester, 'Password', 'abcdefgh1');
      await fill(tester, 'Confirm password', 'abcdefgh2');
      await tapText(tester, 'Update password');
      expect(
        find.text('Add upper and lower case letters and a number.'),
        findsOneWidget,
      );
      expect(find.text('The passwords do not match.'), findsOneWidget);
      expect(find.text('Weak'), findsOneWidget);
      noErrors(tester);
      await unmount(tester);
    });

    testWidgets('an expired reset session offers to start over', (
      WidgetTester tester,
    ) async {
      await openReset(tester, dataSource: _ExpiringDataSource());
      await fill(tester, 'Password', 'Brand-new-2');
      await fill(tester, 'Confirm password', 'Brand-new-2');
      await tapText(tester, 'Update password');
      expect(find.text('Code expired'), findsOneWidget);
      await tapText(tester, 'Start over');
      expect(find.text('Forgot your password?'), findsOneWidget);
      noErrors(tester);
      await unmount(tester);
    });

    testWidgets('the back button skips the spent code and the request', (
      WidgetTester tester,
    ) async {
      await mountAuth(tester);
      await tapText(tester, 'Sign in with email');
      await tapText(tester, 'Forgot password?');
      await fill(tester, 'Email', ada);
      await tapText(tester, 'Send code');
      await tapText(tester, 'Enter code');
      await enterCode(tester, '123456');
      expect(find.text('Choose a new password'), findsOneWidget);
      await tester.tap(backButton);
      await pumpFrames(tester);
      expect(find.text('Welcome back'), findsOneWidget);
      await unmount(tester);
    });
  });

  group('navigation', () {
    for (final (AuthScreen screen, String title) in <(AuthScreen, String)>[
      (AuthScreen.signIn, 'Welcome back'),
      (AuthScreen.signUp, 'Create your account'),
      (AuthScreen.forgotPassword, 'Forgot your password?'),
    ]) {
      testWidgets('can start on ${screen.name}, with no back button', (
        WidgetTester tester,
      ) async {
        await mountAuth(tester, startOn: screen);
        expect(find.text(title), findsOneWidget);
        expect(backButton, findsNothing);
        await unmount(tester);
      });
    }

    testWidgets('returns to the start screen after signing out', (
      WidgetTester tester,
    ) async {
      await mountAuth(tester, startOn: AuthScreen.signIn);
      await fill(tester, 'Email', ada);
      await fill(tester, 'Password', adaPassword);
      await tapText(tester, 'Sign in');
      await tapText(tester, 'Sign out');
      expect(find.text('Welcome back'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets(
      'the system back gesture steps back, then leaves the template alone',
      (WidgetTester tester) async {
        await mountAuth(tester);
        await tapText(tester, 'Sign in with email');
        await tapText(tester, 'Forgot password?');
        expect(find.text('Forgot your password?'), findsOneWidget);

        expect(await tester.binding.handlePopRoute(), isTrue);
        await pumpFrames(tester);
        expect(find.text('Welcome back'), findsOneWidget);

        expect(await tester.binding.handlePopRoute(), isTrue);
        await pumpFrames(tester);
        expect(find.text('Continue with Google'), findsOneWidget);

        // On the root there is nothing to pop, so the host gets the gesture.
        expect(await tester.binding.handlePopRoute(), isFalse);
        noErrors(tester);
        await unmount(tester);
      },
    );

    testWidgets('a screen slides in rather than appearing', (
      WidgetTester tester,
    ) async {
      await mountAuth(tester);
      await tester.tap(find.text('Sign in with email'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final Finder title = find.text('Welcome back');
      final double midway = tester.getTopLeft(title).dx;
      await pumpFrames(tester);
      final double settled = tester.getTopLeft(title).dx;
      expect(midway, greaterThan(settled));
      await unmount(tester);
    });

    testWidgets('with reduced motion screens swap at once', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: CairnTheme.materialTheme(
            CairnTheme.light.copyWith(fontFamily: 'Geist'),
          ),
          builder: (BuildContext context, Widget? child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
          home: Scaffold(
            body: AuthApp(
              authDataSource: InMemoryAuthRemoteDataSource(
                latency: Duration.zero,
              ),
            ),
          ),
        ),
      );
      await pumpFrames(tester);
      await tester.tap(find.text('Sign in with email'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      final double left = tester.getTopLeft(find.text('Welcome back')).dx;
      await pumpFrames(tester);
      expect(tester.getTopLeft(find.text('Welcome back')).dx, left);
      await unmount(tester);
    });
  });

  group('recovery by link', () {
    testWidgets('a reset link opens the reset screen and finishes at sign in', (
      WidgetTester tester,
    ) async {
      // What the server did when it emailed the link.
      final InMemoryAuthRemoteDataSource server = InMemoryAuthRemoteDataSource(
        latency: Duration.zero,
      );
      await server.requestPasswordReset(email: ada);
      final String token =
          (await server.verifyCode(email: ada, code: '123456'))['resetToken']!
              as String;

      await mountAuth(tester, dataSource: server, resetToken: token);
      expect(find.text('Choose a new password'), findsOneWidget);
      expect(backButton, findsNothing);
      await fill(tester, 'Password', 'Linked-new-3');
      await fill(tester, 'Confirm password', 'Linked-new-3');
      await tapText(tester, 'Update password');
      expect(find.text('Password updated'), findsOneWidget);
      await tapText(tester, 'Continue to sign in');
      expect(find.text('Welcome back'), findsOneWidget);
      await fill(tester, 'Email', ada);
      await fill(tester, 'Password', 'Linked-new-3');
      await tapText(tester, 'Sign in');
      expect(find.text('Welcome, Ada'), findsOneWidget);
      noErrors(tester);
      await unmount(tester);
    });

    testWidgets('a link that has already been used says it expired', (
      WidgetTester tester,
    ) async {
      await mountAuth(tester, resetToken: 'never-issued');
      await fill(tester, 'Password', 'Linked-new-3');
      await fill(tester, 'Confirm password', 'Linked-new-3');
      await tapText(tester, 'Update password');
      expect(find.text('Code expired'), findsOneWidget);
      expect(find.text('Start over'), findsOneWidget);
      await tapText(tester, 'Start over');
      expect(find.text('Forgot your password?'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('recoveryByLink drops the code step', (
      WidgetTester tester,
    ) async {
      await mountAuth(
        tester,
        startOn: AuthScreen.forgotPassword,
        recoveryByLink: true,
      );
      await fill(tester, 'Email', ada);
      await tapText(tester, 'Send code');
      expect(find.text('Check your inbox'), findsOneWidget);
      expect(find.textContaining('emailed a link'), findsOneWidget);
      expect(find.text('Enter code'), findsNothing);
      expect(find.text('Back to sign in'), findsOneWidget);
      await unmount(tester);
    });
  });

  group('signed in', () {
    testWidgets('greets the person and explains the hook', (
      WidgetTester tester,
    ) async {
      await mountAuth(tester, startOn: AuthScreen.signIn);
      await fill(tester, 'Email', ada);
      await fill(tester, 'Password', adaPassword);
      await tapText(tester, 'Sign in');
      expect(find.text('Welcome, Ada'), findsOneWidget);
      expect(find.byType(CairnAvatar), findsOneWidget);
      expect(find.text('This screen is a placeholder'), findsOneWidget);
      expect(find.textContaining('onAuthenticated'), findsOneWidget);
      expect(find.text('Sign out'), findsOneWidget);
      expect(backButton, findsNothing);
      await unmount(tester);
    });
  });

  group('layout', () {
    testWidgets('on a tablet the content is a centred column of at most 440', (
      WidgetTester tester,
    ) async {
      await mountAuth(tester, width: 700, startOn: AuthScreen.signIn);
      final Size size = tester.getSize(find.byType(LabeledInput).first);
      expect(size.width, lessThanOrEqualTo(440));
      expect(tester.getCenter(find.byType(LabeledInput).first).dx, 350);
      await unmount(tester);
    });

    testWidgets(
      'on a small phone the content fills the width less its margins',
      (WidgetTester tester) async {
        await mountAuth(tester, width: 320, startOn: AuthScreen.signIn);
        expect(tester.getSize(find.byType(LabeledInput).first).width, 320 - 48);
        await unmount(tester);
      },
    );

    testWidgets(
      'long content scrolls instead of overflowing, with the keyboard up',
      (WidgetTester tester) async {
        await mountAuth(
          tester,
          width: 320,
          height: 640,
          startOn: AuthScreen.signUp,
        );
        tester.view.viewInsets = const FakeViewPadding(bottom: 280);
        addTearDown(tester.view.resetViewInsets);
        await pumpFrames(tester);
        noErrors(tester);
        await reveal(tester, find.text('Create account'));
        noErrors(tester);
        await unmount(tester);
      },
    );

    testWidgets('large system text does not overflow', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: CairnTheme.materialTheme(
            CairnTheme.light.copyWith(fontFamily: 'Geist'),
          ),
          builder: (BuildContext context, Widget? child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.6)),
            child: child!,
          ),
          home: Scaffold(
            body: AuthApp(
              authDataSource: InMemoryAuthRemoteDataSource(
                latency: Duration.zero,
              ),
            ),
          ),
        ),
      );
      await pumpFrames(tester);
      noErrors(tester);
      await tapText(tester, 'Create an account');
      noErrors(tester);
      await tester.tap(backButton);
      await pumpFrames(tester);
      await tapText(tester, 'Sign in with email');
      noErrors(tester);
      await unmount(tester);
    });
  });

  group('right to left', () {
    testWidgets('lays out mirrored, without overflow', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MaterialApp(
          theme: CairnTheme.materialTheme(
            CairnTheme.light.copyWith(fontFamily: 'Geist'),
          ),
          builder: (BuildContext context, Widget? child) =>
              Directionality(textDirection: TextDirection.rtl, child: child!),
          home: Scaffold(
            body: AuthApp(
              startOn: AuthScreen.signUp,
              authDataSource: InMemoryAuthRemoteDataSource(
                latency: Duration.zero,
              ),
            ),
          ),
        ),
      );
      await pumpFrames(tester);
      noErrors(tester);
      expect(tester.getTopRight(find.text('Create your account')).dx, 320 - 24);
      await tapText(tester, 'Create account');
      noErrors(tester);
      await unmount(tester);
    });
  });

  group('accessibility', () {
    testWidgets('errors are part of the field\'s name and announced', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await mountAuth(tester, startOn: AuthScreen.signIn);
      await tapText(tester, 'Sign in');
      expect(
        tester.getSemantics(field('Email')).label,
        allOf(contains('Email'), contains('Enter your email address.')),
      );
      final Finder live = find.ancestor(
        of: find.text('Enter your email address.'),
        matching: find.byWidgetPredicate(
          (Widget w) => w is Semantics && w.properties.liveRegion == true,
        ),
      );
      expect(live, findsOneWidget);
      handle.dispose();
      await unmount(tester);
    });

    testWidgets('alerts are live regions', (WidgetTester tester) async {
      await mountAuth(tester, startOn: AuthScreen.signIn);
      await fill(tester, 'Email', ada);
      await fill(tester, 'Password', 'wrong-one');
      await tapText(tester, 'Sign in');
      expect(
        find.ancestor(
          of: find.text('Could not sign you in'),
          matching: find.byWidgetPredicate(
            (Widget w) => w is Semantics && w.properties.liveRegion == true,
          ),
        ),
        findsOneWidget,
      );
      await unmount(tester);
    });

    testWidgets('icon-only controls have labels', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await mountAuth(tester);
      await tapText(tester, 'Sign in with email');
      expect(find.bySemanticsLabel('Back'), findsOneWidget);
      expect(find.bySemanticsLabel('Show password'), findsOneWidget);
      handle.dispose();
      await unmount(tester);
    });

    testWidgets('the one-time-code field and the strength meter are named', (
      WidgetTester tester,
    ) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      await mountAuth(tester, startOn: AuthScreen.signUp);
      expect(
        find.bySemanticsLabel('Password strength: Choose a strong password'),
        findsOneWidget,
      );
      await fill(tester, 'Password', 'abcdefgh');
      expect(find.bySemanticsLabel('Password strength: Weak'), findsOneWidget);
      handle.dispose();
      await unmount(tester);
    });

    for (final AuthScreen screen in <AuthScreen>[
      AuthScreen.welcome,
      AuthScreen.signIn,
      AuthScreen.signUp,
      AuthScreen.forgotPassword,
    ]) {
      testWidgets(
        'every control on ${screen.name} is at least 44 px tall to tap',
        (WidgetTester tester) async {
          await mountAuth(tester, startOn: screen, width: 320);
          for (final Element e in find.byType(TouchTarget).evaluate()) {
            expect(
              (e.renderObject! as RenderBox).size.height,
              greaterThanOrEqualTo(44),
              reason: 'a TouchTarget on ${screen.name}',
            );
          }
          for (final Element e in find.byType(LabeledInput).evaluate()) {
            final Size field = tester.getSize(
              find
                  .descendant(
                    of: find.byWidget(e.widget),
                    matching: find.byType(Stack),
                  )
                  .first,
            );
            expect(
              field.height,
              greaterThanOrEqualTo(44),
              reason: 'a field on ${screen.name}',
            );
          }
          await unmount(tester);
        },
      );
    }
  });
}
