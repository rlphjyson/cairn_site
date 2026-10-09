import 'package:cairn_template_auth/common/constants/auth_policy.dart';
import 'package:cairn_template_auth/common/constants/demo_account.dart';
import 'package:cairn_template_auth/core/infrastructure/di/auth_injection.dart';
import 'package:cairn_template_auth/core/presentation/form_status.dart';
import 'package:cairn_template_auth/core/presentation/navigation/auth_navigation_cubit.dart';
import 'package:cairn_template_auth/data/auth/remote/in_memory_auth_remote_data_source.dart';
import 'package:cairn_template_auth/domain/auth/models/auth_failure.dart';
import 'package:cairn_template_auth/domain/auth/models/reset_grant.dart';
import 'package:cairn_template_auth/domain/auth/models/social_provider.dart';
import 'package:cairn_template_auth/domain/validation/models/auth_field.dart';
import 'package:cairn_template_auth/domain/validation/models/password_assessment.dart';
import 'package:cairn_template_auth/domain/validation/models/validation_issue.dart';
import 'package:cairn_template_auth/presentation/recovery/bloc/forgot_password_cubit.dart';
import 'package:cairn_template_auth/presentation/recovery/view_models/forgot_password_view_model.dart';
import 'package:cairn_template_auth/presentation/recovery/view_models/reset_password_view_model.dart';
import 'package:cairn_template_auth/presentation/recovery/view_models/verify_code_view_model.dart';
import 'package:cairn_template_auth/presentation/session/bloc/session_cubit.dart';
import 'package:cairn_template_auth/presentation/sign_in/bloc/sign_in_cubit.dart';
import 'package:cairn_template_auth/presentation/sign_in/view_models/sign_in_view_model.dart';
import 'package:cairn_template_auth/presentation/sign_up/bloc/sign_up_cubit.dart';
import 'package:cairn_template_auth/presentation/sign_up/view_models/sign_up_view_model.dart';
import 'package:cairn_template_auth/presentation/welcome/bloc/welcome_cubit.dart';
import 'package:cairn_template_auth/presentation/welcome/view_models/welcome_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'support/fakes.dart';

/// The session cubits wired through the real container, with a fake clock and
/// a fake ticker, and no widgets.
void main() {
  late FakeClock clock;
  late FakeTicker ticker;
  late GetIt locator;

  setUp(() {
    clock = FakeClock();
    ticker = FakeTicker();
    locator = createAuthLocator(
      dataSource: InMemoryAuthRemoteDataSource(
        latency: Duration.zero,
        clock: clock.call,
      ),
      ticker: ticker.call,
      clock: clock.call,
    );
  });

  tearDown(() => locator.reset());

  const AuthDestination here = AuthDestination(AuthScreen.signIn);

  SignInViewModel signInVm() => locator.get<SignInViewModel>(param1: here);

  SignUpViewModel signUpVm() => locator.get<SignUpViewModel>(param1: here);

  Future<VerifyCodeViewModel> verifyVm({bool requested = true}) async {
    if (requested) {
      await locator<ForgotPasswordViewModel>(
        param1: here,
      ).cubit.submit(DemoAccount.email);
    }
    return locator.get<VerifyCodeViewModel>(
      param1: const AuthDestination(
        AuthScreen.verifyCode,
        email: DemoAccount.email,
      ),
    );
  }

  group('SignInCubit', () {
    test('rejects empty fields without calling the server', () async {
      final SignInViewModel vm = signInVm();
      await vm.cubit.submit(email: '', password: '', remember: false);
      expect(vm.cubit.state.status, FormStatus.idle);
      expect(vm.cubit.state.issues, <AuthField, ValidationIssue>{
        AuthField.email: ValidationIssue.emailRequired,
        AuthField.password: ValidationIssue.passwordRequired,
      });
      vm.dispose();
    });

    test('shows an email problem when the field is left, not before', () {
      final SignInViewModel vm = signInVm();
      vm.cubit.validate(AuthField.email, '');
      expect(vm.cubit.state.issues, isEmpty);
      vm.cubit.validate(AuthField.email, 'nope');
      expect(
        vm.cubit.state.issues[AuthField.email],
        ValidationIssue.emailInvalid,
      );
      vm.cubit.edited(AuthField.email);
      expect(vm.cubit.state.issues, isEmpty);
      vm.dispose();
    });

    test('wrong credentials fail without a lock', () async {
      final SignInViewModel vm = signInVm();
      await vm.cubit.submit(
        email: DemoAccount.email,
        password: 'wrong',
        remember: false,
      );
      expect(vm.cubit.state.status, FormStatus.failure);
      expect(vm.cubit.state.failure, AuthFailure.invalidCredentials);
      expect(vm.cubit.state.locked, isFalse);
      // Typing again dismisses the banner.
      vm.cubit.edited(AuthField.password);
      expect(vm.cubit.state.status, FormStatus.idle);
      expect(vm.cubit.state.failure, isNull);
      vm.dispose();
    });

    test(
      'five wrong attempts lock sign-in and the cooldown counts down',
      () async {
        final SignInViewModel vm = signInVm();
        for (int i = 0; i < 5; i++) {
          await vm.cubit.submit(
            email: DemoAccount.email,
            password: 'wrong',
            remember: false,
          );
        }
        expect(vm.cubit.state.failure, AuthFailure.rateLimited);
        expect(
          vm.cubit.state.lockedSeconds,
          AuthPolicy.signInLockout.inSeconds,
        );
        expect(vm.cubit.state.locked, isTrue);
        expect(ticker.active, 1);

        ticker.tick(10);
        expect(vm.cubit.state.lockedSeconds, 20);

        // Typing does not dismiss a lock.
        vm.cubit.edited(AuthField.password);
        expect(vm.cubit.state.locked, isTrue);

        // A submit while locked is ignored (and never reaches the server).
        await vm.cubit.submit(
          email: DemoAccount.email,
          password: DemoAccount.password,
          remember: false,
        );
        expect(vm.cubit.state.status, FormStatus.failure);

        ticker.tick(20);
        expect(vm.cubit.state.locked, isFalse);
        expect(vm.cubit.state.status, FormStatus.idle);
        expect(ticker.active, 0, reason: 'the timer stops itself at zero');

        clock.advance(AuthPolicy.signInLockout);
        await vm.cubit.submit(
          email: DemoAccount.email,
          password: DemoAccount.password,
          remember: false,
        );
        expect(vm.cubit.state.status, FormStatus.success);
        vm.dispose();
      },
    );

    test('closing the cubit cancels the cooldown timer', () async {
      final SignInViewModel vm = signInVm();
      for (int i = 0; i < 5; i++) {
        await vm.cubit.submit(
          email: DemoAccount.email,
          password: 'wrong',
          remember: false,
        );
      }
      expect(ticker.active, 1);
      vm.dispose();
      expect(ticker.active, 0);
    });

    test('a success carries the session and nothing secret', () async {
      final SignInViewModel vm = signInVm();
      await vm.cubit.submit(
        email: DemoAccount.email,
        password: DemoAccount.password,
        remember: true,
      );
      final SignInState state = vm.cubit.state;
      expect(state.status, FormStatus.success);
      expect(state.session!.account.email, DemoAccount.email);
      expect(state.session!.remembered, isTrue);
      final String printed = '$state ${state.props}';
      expect(printed, isNot(contains(DemoAccount.password)));
      expect(printed, isNot(contains(state.session!.accessToken)));
      vm.dispose();
    });

    test('a second submit while one is running is ignored', () async {
      final SignInViewModel vm = signInVm();
      final Future<void> first = vm.cubit.submit(
        email: DemoAccount.email,
        password: 'wrong',
        remember: false,
      );
      final Future<void> second = vm.cubit.submit(
        email: DemoAccount.email,
        password: 'wrong',
        remember: false,
      );
      await Future.wait(<Future<void>>[first, second]);
      // One wrong attempt was counted, so four more are still allowed.
      for (int i = 0; i < 3; i++) {
        await vm.cubit.submit(
          email: DemoAccount.email,
          password: 'wrong',
          remember: false,
        );
      }
      expect(vm.cubit.state.failure, AuthFailure.invalidCredentials);
      vm.dispose();
    });
  });

  group('SignUpCubit', () {
    test('scores the password as it is typed', () {
      final SignUpViewModel vm = signUpVm();
      expect(vm.cubit.state.passwordEmpty, isTrue);
      vm.cubit.passwordChanged('abc');
      expect(vm.cubit.state.assessment.level, PasswordStrengthLevel.tooShort);
      expect(vm.cubit.state.passwordEmpty, isFalse);
      vm.cubit.passwordChanged('Abcdefg1');
      expect(vm.cubit.state.assessment.level, PasswordStrengthLevel.fair);
      vm.cubit.passwordChanged('Cairn-demo-1');
      expect(vm.cubit.state.assessment.level, PasswordStrengthLevel.strong);
      expect(vm.cubit.state.assessment.met, contains(PasswordRule.symbol));
      vm.cubit.passwordChanged('');
      expect(vm.cubit.state.passwordEmpty, isTrue);
      vm.dispose();
    });

    test('reports every problem at once', () async {
      final SignUpViewModel vm = signUpVm();
      await vm.cubit.submit(
        name: 'A',
        email: 'nope',
        password: 'abc',
        confirmation: 'abd',
        acceptedTerms: false,
      );
      expect(vm.cubit.state.issues, <AuthField, ValidationIssue>{
        AuthField.name: ValidationIssue.nameTooShort,
        AuthField.email: ValidationIssue.emailInvalid,
        AuthField.password: ValidationIssue.passwordTooShort,
        AuthField.confirmation: ValidationIssue.confirmationMismatch,
        AuthField.terms: ValidationIssue.termsRequired,
      });
      expect(vm.cubit.state.status, FormStatus.idle);
      vm.dispose();
    });

    test(
      'validates the confirmation against the password when a field is left',
      () {
        final SignUpViewModel vm = signUpVm();
        vm.cubit.validate(AuthField.confirmation, '', password: 'Abcdefg1');
        expect(
          vm.cubit.state.issues,
          isEmpty,
          reason: 'an untouched field is not nagged',
        );
        vm.cubit.validate(
          AuthField.confirmation,
          'Abcdefg2',
          password: 'Abcdefg1',
        );
        expect(
          vm.cubit.state.issues[AuthField.confirmation],
          ValidationIssue.confirmationMismatch,
        );
        vm.cubit.validate(
          AuthField.confirmation,
          'Abcdefg1',
          password: 'Abcdefg1',
        );
        expect(vm.cubit.state.issues, isEmpty);
        vm.dispose();
      },
    );

    test('a taken email becomes an error on the email field', () async {
      final SignUpViewModel vm = signUpVm();
      await vm.cubit.submit(
        name: 'Ada Again',
        email: DemoAccount.email,
        password: 'Abcdefg1',
        confirmation: 'Abcdefg1',
        acceptedTerms: true,
      );
      expect(vm.cubit.state.issues, <AuthField, ValidationIssue>{
        AuthField.email: ValidationIssue.emailTaken,
      });
      expect(vm.cubit.state.status, FormStatus.idle);
      vm.cubit.edited(AuthField.email);
      expect(vm.cubit.state.issues, isEmpty);
      vm.dispose();
    });

    test('creates the account and keeps no password in state', () async {
      final SignUpViewModel vm = signUpVm();
      vm.cubit.passwordChanged('Compile-r-1');
      await vm.cubit.submit(
        name: 'Grace Hopper',
        email: 'grace@example.com',
        password: 'Compile-r-1',
        confirmation: 'Compile-r-1',
        acceptedTerms: true,
      );
      final SignUpState state = vm.cubit.state;
      expect(state.status, FormStatus.success);
      expect(state.session!.account.initials, 'GH');
      expect('$state ${state.props}', isNot(contains('Compile-r-1')));
      vm.dispose();
    });
  });

  group('ForgotPasswordCubit', () {
    test('known and unknown addresses end in the same state', () async {
      final ForgotPasswordViewModel known = locator<ForgotPasswordViewModel>(
        param1: here,
      );
      final ForgotPasswordViewModel unknown = locator<ForgotPasswordViewModel>(
        param1: here,
      );
      await known.cubit.submit(DemoAccount.email);
      await unknown.cubit.submit('nobody@example.com');
      expect(known.cubit.state.status, FormStatus.success);
      expect(unknown.cubit.state.status, FormStatus.success);
      expect(known.cubit.state.failure, unknown.cubit.state.failure);
      expect(known.cubit.state.issue, unknown.cubit.state.issue);
      known.dispose();
      unknown.dispose();
    });

    test('an invalid address never reaches the server', () async {
      final ForgotPasswordViewModel vm = locator<ForgotPasswordViewModel>(
        param1: here,
      );
      await vm.cubit.submit('nope');
      expect(vm.cubit.state.issue, ValidationIssue.emailInvalid);
      expect(vm.cubit.state.status, FormStatus.idle);
      vm.cubit.edited();
      expect(vm.cubit.state.issue, isNull);
      vm.dispose();
    });

    test('can return to the form from the confirmation', () async {
      final ForgotPasswordViewModel vm = locator<ForgotPasswordViewModel>(
        param1: here,
      );
      await vm.cubit.submit(DemoAccount.email);
      expect(vm.cubit.state.sentTo, DemoAccount.email);
      vm.cubit.reset();
      expect(vm.cubit.state, const ForgotPasswordState());
      vm.dispose();
    });
  });

  group('VerifyCodeCubit', () {
    test(
      'starts a cooldown and counts it down with the injected ticker',
      () async {
        final VerifyCodeViewModel vm = await verifyVm();
        expect(vm.cubit.state.resendSeconds, 30);
        expect(ticker.active, 1);
        ticker.tick(29);
        expect(vm.cubit.state.resendSeconds, 1);
        await vm.cubit.resend();
        expect(
          vm.cubit.state.resent,
          isFalse,
          reason: 'resend is ignored during the cooldown',
        );
        ticker.tick();
        expect(vm.cubit.state.resendSeconds, 0);
        expect(ticker.active, 0);
        vm.dispose();
      },
    );

    test('a resend restarts the cooldown and says so', () async {
      final VerifyCodeViewModel vm = await verifyVm();
      ticker.tick(30);
      await vm.cubit.resend();
      expect(vm.cubit.state.resent, isTrue);
      expect(vm.cubit.state.resending, isFalse);
      expect(vm.cubit.state.resendSeconds, 30);
      expect(ticker.active, 1);
      // Typing a digit clears the notice.
      vm.cubit.edited('1');
      expect(vm.cubit.state.resent, isFalse);
      vm.dispose();
    });

    test('closing cancels the timer', () async {
      final VerifyCodeViewModel vm = await verifyVm();
      expect(ticker.active, 1);
      vm.dispose();
      expect(ticker.active, 0);
    });

    test(
      'a wrong code reports the attempts left; the right one succeeds',
      () async {
        final VerifyCodeViewModel vm = await verifyVm();
        await vm.cubit.submit('000000');
        expect(vm.cubit.state.failure, AuthFailure.invalidCode);
        expect(vm.cubit.state.attemptsRemaining, 4);
        expect(vm.cubit.state.locked, isFalse);
        // An emptied field (cleared after the miss) keeps the message.
        vm.cubit.edited('');
        expect(vm.cubit.state.failure, AuthFailure.invalidCode);
        vm.cubit.edited('1');
        expect(vm.cubit.state.failure, isNull);

        await vm.cubit.submit(DemoAccount.code);
        expect(vm.cubit.state.status, FormStatus.success);
        expect(vm.cubit.state.grant, isA<ResetGrant>());
        expect(
          '${vm.cubit.state} ${vm.cubit.state.props}',
          isNot(contains(vm.cubit.state.grant!.token)),
        );
        vm.dispose();
      },
    );

    test('five wrong codes lock it until a new code is requested', () async {
      final VerifyCodeViewModel vm = await verifyVm();
      for (int i = 0; i < 5; i++) {
        await vm.cubit.submit('000000');
      }
      expect(vm.cubit.state.failure, AuthFailure.tooManyAttempts);
      expect(vm.cubit.state.locked, isTrue);

      // Even the right code is refused while locked.
      await vm.cubit.submit(DemoAccount.code);
      expect(vm.cubit.state.status, FormStatus.failure);

      // A new code needs the cooldown to be over first.
      await vm.cubit.resend();
      expect(vm.cubit.state.locked, isTrue);
      ticker.tick(30);
      await vm.cubit.resend();
      expect(vm.cubit.state.locked, isFalse);
      expect(vm.cubit.state.resent, isTrue);

      await vm.cubit.submit(DemoAccount.code);
      expect(vm.cubit.state.status, FormStatus.success);
      vm.dispose();
    });

    test('an expired code asks for a new one', () async {
      final VerifyCodeViewModel vm = await verifyVm();
      clock.advance(AuthPolicy.codeLifetime + const Duration(seconds: 1));
      await vm.cubit.submit(DemoAccount.code);
      expect(vm.cubit.state.failure, AuthFailure.codeExpired);
      expect(vm.cubit.state.locked, isTrue);
      ticker.tick(30);
      await vm.cubit.resend();
      await vm.cubit.submit(DemoAccount.code);
      expect(vm.cubit.state.status, FormStatus.success);
      vm.dispose();
    });
  });

  group('ResetPasswordCubit', () {
    Future<ResetPasswordViewModel> resetVm() async {
      final VerifyCodeViewModel verify = await verifyVm();
      await verify.cubit.submit(DemoAccount.code);
      final ResetGrant grant = verify.cubit.state.grant!;
      verify.dispose();
      return locator.get<ResetPasswordViewModel>(
        param1: AuthDestination(
          AuthScreen.resetPassword,
          email: DemoAccount.email,
          grant: grant,
        ),
      );
    }

    test('checks the password and the confirmation', () async {
      final ResetPasswordViewModel vm = await resetVm();
      await vm.cubit.submit(password: 'abc', confirmation: 'abd');
      expect(vm.cubit.state.issues, <AuthField, ValidationIssue>{
        AuthField.password: ValidationIssue.passwordTooShort,
        AuthField.confirmation: ValidationIssue.confirmationMismatch,
      });
      vm.cubit.passwordChanged('Abcdefg1');
      expect(vm.cubit.state.assessment.level, PasswordStrengthLevel.fair);
      expect(vm.cubit.state.issues.containsKey(AuthField.password), isFalse);
      vm.dispose();
    });

    test('a new password replaces the old one on the server', () async {
      final ResetPasswordViewModel vm = await resetVm();
      await vm.cubit.submit(
        password: 'Brand-new-2',
        confirmation: 'Brand-new-2',
      );
      expect(vm.cubit.state.status, FormStatus.success);
      expect(
        '${vm.cubit.state} ${vm.cubit.state.props}',
        isNot(contains('Brand-new-2')),
      );
      vm.dispose();

      final SignInViewModel signIn = signInVm();
      await signIn.cubit.submit(
        email: DemoAccount.email,
        password: DemoAccount.password,
        remember: false,
      );
      expect(signIn.cubit.state.failure, AuthFailure.invalidCredentials);
      await signIn.cubit.submit(
        email: DemoAccount.email,
        password: 'Brand-new-2',
        remember: false,
      );
      expect(signIn.cubit.state.status, FormStatus.success);
      signIn.dispose();
    });

    test('a spent grant is reported as expired', () async {
      final ResetPasswordViewModel vm = await resetVm();
      await vm.cubit.submit(
        password: 'Brand-new-2',
        confirmation: 'Brand-new-2',
      );
      final ResetPasswordViewModel again = locator.get<ResetPasswordViewModel>(
        param1: const AuthDestination(
          AuthScreen.resetPassword,
          grant: ResetGrant('reset-1'),
        ),
      );
      await again.cubit.submit(
        password: 'Brand-new-3',
        confirmation: 'Brand-new-3',
      );
      expect(again.cubit.state.failure, AuthFailure.codeExpired);
      vm.dispose();
      again.dispose();
    });
  });

  group('WelcomeCubit', () {
    test('signs in with a provider using the placeholder token', () async {
      final WelcomeViewModel vm = locator.get<WelcomeViewModel>(
        param1: const AuthDestination(AuthScreen.welcome),
      );
      await vm.cubit.continueWith(SocialProvider.google);
      expect(vm.cubit.state.status, FormStatus.success);
      expect(vm.cubit.state.session!.account.id, 'social-google');
      vm.dispose();
    });

    test('a cancelled provider sheet returns to idle with no error', () async {
      final GetIt cancelling = createAuthLocator(
        dataSource: InMemoryAuthRemoteDataSource(latency: Duration.zero),
        socialIdToken: (SocialProvider p) async => null,
      );
      final WelcomeViewModel vm = cancelling.get<WelcomeViewModel>(
        param1: const AuthDestination(AuthScreen.welcome),
      );
      await vm.cubit.continueWith(SocialProvider.apple);
      expect(vm.cubit.state, const WelcomeState());
      vm.dispose();
      await cancelling.reset();
    });

    test(
      'a failing SDK becomes an offline message that can be dismissed',
      () async {
        final GetIt failing = createAuthLocator(
          dataSource: InMemoryAuthRemoteDataSource(latency: Duration.zero),
          socialIdToken: (SocialProvider p) async => throw StateError('boom'),
        );
        final WelcomeViewModel vm = failing.get<WelcomeViewModel>(
          param1: const AuthDestination(AuthScreen.welcome),
        );
        await vm.cubit.continueWith(SocialProvider.google);
        expect(vm.cubit.state.failure, AuthFailure.network);
        vm.cubit.dismissError();
        expect(vm.cubit.state, const WelcomeState());
        vm.dispose();
        await failing.reset();
      },
    );
  });

  group('SessionCubit', () {
    test('starts and ends a session', () async {
      final SessionCubit cubit = locator<SessionCubit>();
      expect(cubit.state.signedIn, isFalse);
      final SignInViewModel vm = signInVm();
      await vm.cubit.submit(
        email: DemoAccount.email,
        password: DemoAccount.password,
        remember: false,
      );
      cubit.start(vm.cubit.state.session!);
      vm.dispose();
      expect(cubit.state.signedIn, isTrue);
      expect(cubit.state.session!.account.name, DemoAccount.name);

      final Future<void> out = cubit.signOut();
      expect(cubit.state.signingOut, isTrue);
      await out;
      expect(cubit.state.signedIn, isFalse);
      expect(cubit.state.signingOut, isFalse);
    });

    test('signing out while signed out does nothing', () async {
      final SessionCubit cubit = locator<SessionCubit>();
      await cubit.signOut();
      expect(cubit.state, const SessionState());
    });

    test('is a singleton, and each locator has its own', () {
      expect(locator<SessionCubit>(), same(locator<SessionCubit>()));
      final GetIt other = createAuthLocator();
      expect(other<SessionCubit>(), isNot(same(locator<SessionCubit>())));
      other.reset();
    });

    test('resetting the container closes the session cubits', () async {
      final SessionCubit session = locator<SessionCubit>();
      final AuthNavigationCubit nav = locator<AuthNavigationCubit>();
      await locator.reset();
      expect(session.isClosed, isTrue);
      expect(nav.isClosed, isTrue);
    });
  });

  group('AuthNavigationCubit', () {
    late AuthNavigationCubit nav;

    setUp(() => nav = AuthNavigationCubit());
    tearDown(() => nav.close());

    List<AuthScreen> screens() =>
        nav.state.stack.map((AuthDestination d) => d.screen).toList();

    test('starts on the chosen screen with nowhere to go back to', () {
      expect(screens(), <AuthScreen>[AuthScreen.welcome]);
      expect(nav.state.canGoBack, isFalse);
      nav.back();
      expect(screens(), <AuthScreen>[AuthScreen.welcome]);
      final AuthNavigationCubit other = AuthNavigationCubit(
        start: AuthScreen.signUp,
      );
      expect(other.state.top.screen, AuthScreen.signUp);
      other.close();
    });

    test('opens on the reset screen when a link brought a grant', () {
      final AuthNavigationCubit linked = AuthNavigationCubit(
        resetGrant: const ResetGrant('from-link'),
      );
      expect(linked.state.top.screen, AuthScreen.resetPassword);
      expect(linked.state.top.grant, const ResetGrant('from-link'));
      expect(linked.state.canGoBack, isFalse);
      linked.resetToStart();
      expect(linked.state.top.screen, AuthScreen.welcome);
      linked.close();
    });

    test('push and back keep a stack; every visit has its own id', () {
      nav
        ..push(AuthScreen.signIn)
        ..push(AuthScreen.signUp);
      expect(screens(), <AuthScreen>[
        AuthScreen.welcome,
        AuthScreen.signIn,
        AuthScreen.signUp,
      ]);
      expect(nav.state.canGoBack, isTrue);
      final Set<int> ids = nav.state.stack
          .map((AuthDestination d) => d.id)
          .toSet();
      expect(ids.length, 3);
      nav.back();
      expect(nav.state.top.screen, AuthScreen.signIn);
    });

    test('replaceTop swaps the current screen', () {
      nav
        ..push(AuthScreen.forgotPassword, email: 'a@b.co')
        ..replaceTop(AuthScreen.verifyCode, email: 'a@b.co');
      expect(screens(), <AuthScreen>[
        AuthScreen.welcome,
        AuthScreen.verifyCode,
      ]);
      expect(nav.state.top.email, 'a@b.co');
    });

    test('switchTo returns to a screen below instead of growing the stack', () {
      nav
        ..push(AuthScreen.signIn)
        ..push(AuthScreen.signUp);
      final AuthDestination signIn = nav.state.stack[1];
      nav.switchTo(AuthScreen.signIn);
      expect(screens(), <AuthScreen>[AuthScreen.welcome, AuthScreen.signIn]);
      expect(
        nav.state.top,
        signIn,
        reason: 'the same page, so it keeps its form',
      );
    });

    test('switchTo with fresh rebuilds the screen it returns to', () {
      nav
        ..push(AuthScreen.signIn)
        ..push(AuthScreen.forgotPassword);
      final AuthDestination old = nav.state.stack[1];
      nav.switchTo(AuthScreen.signIn, email: 'a@b.co', fresh: true);
      expect(screens(), <AuthScreen>[AuthScreen.welcome, AuthScreen.signIn]);
      expect(nav.state.top, isNot(old));
      expect(nav.state.top.email, 'a@b.co');
    });

    test(
      'switchTo replaces the current screen when the target is not below',
      () {
        nav
          ..push(AuthScreen.signUp)
          ..switchTo(AuthScreen.signIn);
        expect(screens(), <AuthScreen>[AuthScreen.welcome, AuthScreen.signIn]);
      },
    );

    test(
      'replaceTrailing drops the finished flow and pushes the next step',
      () {
        nav
          ..push(AuthScreen.signIn)
          ..push(AuthScreen.forgotPassword)
          ..push(AuthScreen.verifyCode, email: 'a@b.co')
          ..replaceTrailing(
            <AuthScreen>{AuthScreen.verifyCode, AuthScreen.forgotPassword},
            AuthScreen.resetPassword,
            email: 'a@b.co',
          );
        expect(screens(), <AuthScreen>[
          AuthScreen.welcome,
          AuthScreen.signIn,
          AuthScreen.resetPassword,
        ]);
        expect(nav.state.top.email, 'a@b.co');
      },
    );

    test('replaceTrailing can empty the stack when the flow was the start', () {
      final AuthNavigationCubit flow = AuthNavigationCubit(
        start: AuthScreen.forgotPassword,
      )..push(AuthScreen.verifyCode);
      flow.replaceTrailing(<AuthScreen>{
        AuthScreen.verifyCode,
        AuthScreen.forgotPassword,
      }, AuthScreen.resetPassword);
      expect(
        flow.state.stack.map((AuthDestination d) => d.screen),
        <AuthScreen>[AuthScreen.resetPassword],
      );
      expect(flow.state.canGoBack, isFalse);
      flow.close();
    });

    test('resetTo and resetToStart replace the whole stack', () {
      nav
        ..push(AuthScreen.signIn)
        ..resetTo(<AuthScreen>[AuthScreen.signedIn]);
      expect(screens(), <AuthScreen>[AuthScreen.signedIn]);
      nav.resetToStart();
      expect(screens(), <AuthScreen>[AuthScreen.welcome]);
    });

    test('didPop follows a pop the navigator made itself, once', () {
      nav
        ..push(AuthScreen.signIn)
        ..push(AuthScreen.signUp);
      final AuthDestination top = nav.state.top;
      nav.didPop(top);
      expect(nav.state.top.screen, AuthScreen.signIn);
      nav.didPop(top);
      expect(
        nav.state.top.screen,
        AuthScreen.signIn,
        reason: 'a stale pop is ignored',
      );
    });
  });
}
