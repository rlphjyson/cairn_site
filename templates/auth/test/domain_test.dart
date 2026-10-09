import 'package:cairn_template_auth/common/constants/auth_policy.dart';
import 'package:cairn_template_auth/common/constants/demo_account.dart';
import 'package:cairn_template_auth/common/utils/attempt_limiter.dart';
import 'package:cairn_template_auth/data/auth/remote/auth_remote_data_source.dart';
import 'package:cairn_template_auth/data/auth/remote/in_memory_auth_remote_data_source.dart';
import 'package:cairn_template_auth/data/auth/repositories/auth_repository_impl.dart';
import 'package:cairn_template_auth/domain/auth/mappers/auth_mapper.dart';
import 'package:cairn_template_auth/domain/auth/models/account.dart';
import 'package:cairn_template_auth/domain/auth/models/auth_failure.dart';
import 'package:cairn_template_auth/domain/auth/models/reset_grant.dart';
import 'package:cairn_template_auth/domain/auth/models/session.dart';
import 'package:cairn_template_auth/domain/auth/models/social_provider.dart';
import 'package:cairn_template_auth/domain/auth/repositories/auth_repository.dart';
import 'package:cairn_template_auth/domain/auth/use_cases/request_password_reset.dart';
import 'package:cairn_template_auth/domain/auth/use_cases/reset_password.dart';
import 'package:cairn_template_auth/domain/auth/use_cases/sign_in.dart';
import 'package:cairn_template_auth/domain/auth/use_cases/sign_in_with_provider.dart';
import 'package:cairn_template_auth/domain/auth/use_cases/sign_out.dart';
import 'package:cairn_template_auth/domain/auth/use_cases/sign_up.dart';
import 'package:cairn_template_auth/domain/auth/use_cases/verify_code.dart';
import 'package:cairn_template_auth/domain/validation/models/password_assessment.dart';
import 'package:cairn_template_auth/domain/validation/models/validation_issue.dart';
import 'package:cairn_template_auth/domain/validation/use_cases/password_strength.dart';
import 'package:cairn_template_auth/domain/validation/use_cases/validate_code.dart';
import 'package:cairn_template_auth/domain/validation/use_cases/validate_email.dart';
import 'package:cairn_template_auth/domain/validation/use_cases/validate_name.dart';
import 'package:cairn_template_auth/domain/validation/use_cases/validate_password.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fakes.dart';

/// Records what the use cases hand to the repository.
class _FakeRepository implements AuthRepository {
  final List<String> calls = <String>[];
  Object? error;
  Map<String, Object?> last = <String, Object?>{};

  static const Account _account = Account(
    id: 'u1',
    name: 'Test User',
    email: 'test@example.com',
  );

  Future<T> _run<T>(String name, Map<String, Object?> args, T value) async {
    calls.add(name);
    last = args;
    if (error != null) throw error!;
    return value;
  }

  @override
  Future<Session> signIn({
    required String email,
    required String password,
    required bool remember,
  }) => _run('signIn', <String, Object?>{
    'email': email,
    'password': password,
    'remember': remember,
  }, const Session(account: _account, accessToken: 't'));

  @override
  Future<Session> signUp({
    required String name,
    required String email,
    required String password,
  }) => _run('signUp', <String, Object?>{
    'name': name,
    'email': email,
    'password': password,
  }, const Session(account: _account, accessToken: 't'));

  @override
  Future<Session> signInWithProvider({
    required SocialProvider provider,
    required String idToken,
  }) => _run('social', <String, Object?>{
    'provider': provider,
    'idToken': idToken,
  }, const Session(account: _account, accessToken: 't'));

  @override
  Future<void> requestPasswordReset(String email) =>
      _run('request', <String, Object?>{'email': email}, null);

  @override
  Future<ResetGrant> verifyCode({
    required String email,
    required String code,
  }) => _run('verify', <String, Object?>{
    'email': email,
    'code': code,
  }, const ResetGrant('grant'));

  @override
  Future<void> resetPassword({
    required ResetGrant grant,
    required String password,
  }) => _run('reset', <String, Object?>{
    'grant': grant,
    'password': password,
  }, null);

  @override
  Future<void> signOut() => _run('signOut', <String, Object?>{}, null);
}

/// A data source whose answers the test chooses.
class _ScriptedDataSource implements AuthRemoteDataSource {
  _ScriptedDataSource(this.respond);

  final Future<Map<String, Object?>> Function() respond;

  @override
  Future<Map<String, Object?>> signIn({
    required String email,
    required String password,
    required bool remember,
  }) => respond();

  @override
  Future<Map<String, Object?>> signUp({
    required String name,
    required String email,
    required String password,
  }) => respond();

  @override
  Future<Map<String, Object?>> signInWithProvider({
    required String provider,
    required String idToken,
  }) => respond();

  @override
  Future<Map<String, Object?>> requestPasswordReset({required String email}) =>
      respond();

  @override
  Future<Map<String, Object?>> verifyCode({
    required String email,
    required String code,
  }) => respond();

  @override
  Future<Map<String, Object?>> resetPassword({
    required String resetToken,
    required String password,
  }) => respond();

  @override
  Future<Map<String, Object?>> signOut() => respond();
}

Matcher _failsWith(AuthFailure failure, {ValidationIssue? issue}) => throwsA(
  isA<AuthException>()
      .having((AuthException e) => e.failure, 'failure', failure)
      .having((AuthException e) => e.issue, 'issue', issue),
);

void main() {
  group('ValidateEmail', () {
    const ValidateEmail validate = ValidateEmail();

    test('accepts ordinary addresses', () {
      for (final String email in <String>[
        'ada@example.com',
        'a.b+tag@sub.example.co.uk',
        '  padded@example.com  ',
        'x@y.io',
      ]) {
        expect(validate(email), isNull, reason: email);
      }
    });

    test('says what is wrong', () {
      expect(validate(''), ValidationIssue.emailRequired);
      expect(validate('   '), ValidationIssue.emailRequired);
      for (final String email in <String>[
        'plain',
        'no-at.example.com',
        '@example.com',
        'a@',
        'a@b',
        'a@b.',
        'a@.com',
        'a b@example.com',
        'a@@example.com',
        'a@b..com',
      ]) {
        expect(validate(email), ValidationIssue.emailInvalid, reason: email);
      }
      expect(
        validate('${'a' * 250}@example.com'),
        ValidationIssue.emailInvalid,
      );
    });
  });

  group('ValidateName', () {
    const ValidateName validate = ValidateName();

    test('needs a name of at least two characters', () {
      expect(validate(''), ValidationIssue.nameRequired);
      expect(validate('  '), ValidationIssue.nameRequired);
      expect(validate('A'), ValidationIssue.nameTooShort);
      expect(validate('Al'), isNull);
      expect(validate('Ada Lovelace'), isNull);
    });
  });

  group('PasswordStrength', () {
    const PasswordStrength strength = PasswordStrength();

    test('empty scores nothing', () {
      expect(strength(''), PasswordAssessment.empty);
      expect(strength('').score, 0);
    });

    test('under the minimum length is too short, and fills a little', () {
      final PasswordAssessment a = strength('Ab1');
      expect(a.level, PasswordStrengthLevel.tooShort);
      expect(a.score, greaterThan(0));
      expect(a.score, lessThanOrEqualTo(0.2));
      expect(a.met, isNot(contains(PasswordRule.minLength)));
      expect(strength('Ab1!xyz').level, PasswordStrengthLevel.tooShort);
    });

    test('long but plain is weak', () {
      expect(strength('abcdefgh').level, PasswordStrengthLevel.weak);
      expect(strength('abcdefg1').level, PasswordStrengthLevel.weak);
      expect(strength('ABCDEFGH').level, PasswordStrengthLevel.weak);
    });

    test('mixed case and a number is fair', () {
      final PasswordAssessment a = strength('Abcdefg1');
      expect(a.level, PasswordStrengthLevel.fair);
      expect(
        a.met,
        containsAll(<PasswordRule>[
          PasswordRule.minLength,
          PasswordRule.mixedCase,
          PasswordRule.number,
        ]),
      );
      expect(a.met, isNot(contains(PasswordRule.symbol)));
    });

    test('a symbol or extra length makes it strong', () {
      expect(strength('Abcdef1!').level, PasswordStrengthLevel.strong);
      expect(strength('Cairn-demo-1').level, PasswordStrengthLevel.strong);
      expect(strength('Abcdefghijk1').level, PasswordStrengthLevel.strong);
    });

    test('common passwords stay weak however they are cased', () {
      for (final String p in <String>['Password1', 'PASSWORD', 'Passw0rd']) {
        final PasswordAssessment a = strength(p);
        expect(a.isCommon, isTrue, reason: p);
        expect(a.level, PasswordStrengthLevel.weak, reason: p);
        expect(a.meetsPolicy, isFalse, reason: p);
      }
    });

    test('the score only ever goes up with the level', () {
      final List<double> scores = <String>[
        'Ab1',
        'abcdefgh',
        'Abcdefg1',
        'Cairn-demo-1',
      ].map((String p) => strength(p).score).toList();
      expect(scores, orderedEquals(<double>[...scores]..sort()));
      expect(scores.last, 1);
    });

    test('meetsPolicy needs the required rules, not the symbol', () {
      expect(strength('Abcdefg1').meetsPolicy, isTrue);
      expect(strength('abcdefg1').meetsPolicy, isFalse);
      expect(strength('Abcdefgh').meetsPolicy, isFalse);
    });
  });

  group('ValidatePassword', () {
    const ValidatePassword validate = ValidatePassword(PasswordStrength());

    test('reports the first problem', () {
      expect(validate(''), ValidationIssue.passwordRequired);
      expect(validate('Ab1'), ValidationIssue.passwordTooShort);
      expect(validate('Password1'), ValidationIssue.passwordTooCommon);
      expect(validate('abcdefgh1'), ValidationIssue.passwordTooWeak);
      expect(validate('Abcdefg1'), isNull);
      expect(validate('Cairn-demo-1'), isNull);
    });

    test('confirmation must be present and equal', () {
      expect(
        validate.confirm('Abcdefg1', ''),
        ValidationIssue.confirmationRequired,
      );
      expect(
        validate.confirm('Abcdefg1', 'abcdefg1'),
        ValidationIssue.confirmationMismatch,
      );
      expect(validate.confirm('Abcdefg1', 'Abcdefg1'), isNull);
    });
  });

  group('ValidateCode', () {
    const ValidateCode validate = ValidateCode();

    test('needs exactly six digits', () {
      expect(validate('123456'), isNull);
      expect(validate(' 123456 '), isNull);
      for (final String code in <String>[
        '',
        '12345',
        '1234567',
        '12a456',
        '123 56',
      ]) {
        expect(validate(code), ValidationIssue.codeIncomplete, reason: code);
      }
    });
  });

  group('AttemptLimiter', () {
    late FakeClock clock;
    late AttemptLimiter limiter;

    setUp(() {
      clock = FakeClock();
      limiter = AttemptLimiter(
        maxAttempts: 5,
        lockout: const Duration(seconds: 30),
        clock: clock.call,
      );
    });

    test('allows four failures and locks on the fifth', () {
      for (int i = 0; i < 4; i++) {
        expect(limiter.recordFailure('a'), isNull);
        expect(limiter.lockedFor('a'), isNull);
      }
      expect(limiter.attemptsLeft('a'), 1);
      expect(limiter.recordFailure('a'), const Duration(seconds: 30));
      expect(limiter.lockedFor('a'), const Duration(seconds: 30));
    });

    test('the lock runs down with the clock and then clears', () {
      for (int i = 0; i < 5; i++) {
        limiter.recordFailure('a');
      }
      clock.advance(const Duration(seconds: 12));
      expect(limiter.lockedFor('a'), const Duration(seconds: 18));
      expect(limiter.recordFailure('a'), const Duration(seconds: 18));
      clock.advance(const Duration(seconds: 18));
      expect(limiter.lockedFor('a'), isNull);
      expect(limiter.attemptsLeft('a'), 5);
    });

    test('keys are independent and reset forgets one', () {
      for (int i = 0; i < 5; i++) {
        limiter.recordFailure('a');
      }
      expect(limiter.lockedFor('b'), isNull);
      limiter.recordFailure('b');
      limiter.reset('a');
      expect(limiter.lockedFor('a'), isNull);
      expect(limiter.attemptsLeft('a'), 5);
      expect(limiter.attemptsLeft('b'), 4);
    });
  });

  group('models', () {
    test('Account initials and first name', () {
      const Account ada = Account(
        id: '1',
        name: 'Ada Lovelace',
        email: 'a@b.co',
      );
      expect(ada.initials, 'AL');
      expect(ada.firstName, 'Ada');
      expect(
        const Account(
          id: '1',
          name: 'Ada King Lovelace',
          email: 'a@b.co',
        ).initials,
        'AL',
      );
      expect(
        const Account(id: '1', name: 'cher', email: 'a@b.co').initials,
        'C',
      );
      expect(
        const Account(id: '1', name: '  ', email: 'zed@b.co').initials,
        'Z',
      );
      expect(
        const Account(id: '1', name: '', email: 'zed@b.co').firstName,
        'zed@b.co',
      );
    });

    test('Session and ResetGrant never print their tokens', () {
      const Session session = Session(
        account: Account(id: '1', name: 'Ada', email: 'a@b.co'),
        accessToken: 'super-secret-token',
        refreshToken: 'super-secret-refresh',
      );
      expect(session.toString(), isNot(contains('super-secret-token')));
      expect(session.toString(), isNot(contains('super-secret-refresh')));
      expect(session.props, isNot(contains('super-secret-refresh')));
      expect(session.toString(), contains('redacted'));
      expect(
        const ResetGrant('reset-secret').toString(),
        isNot(contains('secret')),
      );
    });

    test('Session equality ignores the token', () {
      const Account account = Account(id: '1', name: 'Ada', email: 'a@b.co');
      expect(
        const Session(account: account, accessToken: 'one'),
        const Session(account: account, accessToken: 'two'),
      );
    });
  });

  group('AuthMapper', () {
    final DateTime now = DateTime.utc(2026, 1, 1);

    test('maps a session body', () {
      final Session s = AuthMapper.sessionFromJson(
        <String, Object?>{
          'user': <String, Object?>{
            'id': 'u',
            'name': 'Ada',
            'email': 'a@b.co',
          },
          'accessToken': 'tok',
          'refreshToken': 'refresh',
          'expiresIn': 3600,
        },
        now: now,
        remembered: true,
      );
      expect(s.account.email, 'a@b.co');
      expect(s.accessToken, 'tok');
      expect(s.refreshToken, 'refresh');
      expect(s.expiresAt, now.add(const Duration(hours: 1)));
      expect(s.remembered, isTrue);
    });

    test('a missing name becomes empty, a missing expiry null', () {
      final Session s = AuthMapper.sessionFromJson(<String, Object?>{
        'user': <String, Object?>{'id': 'u', 'email': 'a@b.co'},
        'accessToken': 'tok',
      }, now: now);
      expect(s.account.name, '');
      expect(s.expiresAt, isNull);
      expect(s.refreshToken, isNull);
    });

    test('an error envelope throws the matching failure', () {
      expect(
        () => AuthMapper.sessionFromJson(<String, Object?>{
          'error': <String, Object?>{
            'code': 'rate_limited',
            'retryAfterSeconds': 30,
          },
        }, now: now),
        throwsA(
          isA<AuthException>()
              .having(
                (AuthException e) => e.failure,
                'failure',
                AuthFailure.rateLimited,
              )
              .having(
                (AuthException e) => e.retryAfter,
                'retryAfter',
                const Duration(seconds: 30),
              ),
        ),
      );
      expect(
        () => AuthMapper.resetGrantFromJson(<String, Object?>{
          'error': <String, Object?>{
            'code': 'invalid_code',
            'attemptsRemaining': 3,
          },
        }),
        throwsA(
          isA<AuthException>().having(
            (AuthException e) => e.attemptsRemaining,
            'attemptsRemaining',
            3,
          ),
        ),
      );
    });

    test('every documented code maps, anything else is unknown', () {
      expect(
        AuthMapper.failureFromCode('invalid_credentials'),
        AuthFailure.invalidCredentials,
      );
      expect(AuthMapper.failureFromCode('email_taken'), AuthFailure.emailTaken);
      expect(
        AuthMapper.failureFromCode('rate_limited'),
        AuthFailure.rateLimited,
      );
      expect(
        AuthMapper.failureFromCode('invalid_code'),
        AuthFailure.invalidCode,
      );
      expect(
        AuthMapper.failureFromCode('code_expired'),
        AuthFailure.codeExpired,
      );
      expect(
        AuthMapper.failureFromCode('too_many_attempts'),
        AuthFailure.tooManyAttempts,
      );
      expect(AuthMapper.failureFromCode('nope'), AuthFailure.unknown);
      expect(AuthMapper.failureFromCode(null), AuthFailure.unknown);
    });

    test('a body without an error passes through', () {
      expect(
        () => AuthMapper.throwIfError(<String, Object?>{'ok': true}),
        returnsNormally,
      );
    });
  });

  group('use cases', () {
    late _FakeRepository repo;
    late SignIn signIn;
    late SignUp signUp;
    late RequestPasswordReset request;
    late VerifyCode verify;
    late ResetPassword reset;

    setUp(() {
      repo = _FakeRepository();
      const ValidateEmail email = ValidateEmail();
      const ValidatePassword password = ValidatePassword(PasswordStrength());
      signIn = SignIn(repo, email);
      signUp = SignUp(repo, const ValidateName(), email, password);
      request = RequestPasswordReset(repo, email);
      verify = VerifyCode(repo, const ValidateCode());
      reset = ResetPassword(repo, password);
    });

    test('SignIn validates before calling the repository', () async {
      await expectLater(
        signIn(email: 'nope', password: 'x'),
        _failsWith(
          AuthFailure.invalidInput,
          issue: ValidationIssue.emailInvalid,
        ),
      );
      await expectLater(
        signIn(email: '', password: 'x'),
        _failsWith(
          AuthFailure.invalidInput,
          issue: ValidationIssue.emailRequired,
        ),
      );
      await expectLater(
        signIn(email: 'a@b.co', password: ''),
        _failsWith(
          AuthFailure.invalidInput,
          issue: ValidationIssue.passwordRequired,
        ),
      );
      expect(repo.calls, isEmpty);
    });

    test('SignIn trims the email but never the password', () async {
      await signIn(email: '  a@b.co ', password: ' pass ', remember: true);
      expect(repo.last, <String, Object?>{
        'email': 'a@b.co',
        'password': ' pass ',
        'remember': true,
      });
    });

    test(
      'SignIn does not apply the new-password policy to old passwords',
      () async {
        await signIn(email: 'a@b.co', password: 'short');
        expect(repo.calls, <String>['signIn']);
      },
    );

    test(
      'SignIn passes repository failures through, lockout included',
      () async {
        repo.error = const AuthException(
          AuthFailure.rateLimited,
          retryAfter: Duration(seconds: 30),
        );
        await expectLater(
          signIn(email: 'a@b.co', password: 'x'),
          throwsA(
            isA<AuthException>().having(
              (AuthException e) => e.retryAfter,
              'retryAfter',
              const Duration(seconds: 30),
            ),
          ),
        );
      },
    );

    test('SignUp checks every field, in order', () async {
      Future<void> expectIssue(
        ValidationIssue issue, {
        String name = 'Ada',
        String email = 'a@b.co',
        String password = 'Abcdefg1',
        String confirmation = 'Abcdefg1',
        bool terms = true,
      }) => expectLater(
        signUp(
          name: name,
          email: email,
          password: password,
          confirmation: confirmation,
          acceptedTerms: terms,
        ),
        _failsWith(AuthFailure.invalidInput, issue: issue),
      );

      await expectIssue(ValidationIssue.nameRequired, name: '');
      await expectIssue(ValidationIssue.emailInvalid, email: 'x');
      await expectIssue(
        ValidationIssue.passwordTooShort,
        password: 'Ab1',
        confirmation: 'Ab1',
      );
      await expectIssue(
        ValidationIssue.passwordTooWeak,
        password: 'abcdefgh1',
        confirmation: 'abcdefgh1',
      );
      await expectIssue(
        ValidationIssue.confirmationMismatch,
        confirmation: 'Abcdefg2',
      );
      await expectIssue(ValidationIssue.termsRequired, terms: false);
      expect(repo.calls, isEmpty);
    });

    test('SignUp sends trimmed name and email', () async {
      await signUp(
        name: ' Ada Lovelace ',
        email: ' a@b.co ',
        password: 'Abcdefg1',
        confirmation: 'Abcdefg1',
        acceptedTerms: true,
      );
      expect(repo.last['name'], 'Ada Lovelace');
      expect(repo.last['email'], 'a@b.co');
    });

    test('RequestPasswordReset validates and trims', () async {
      await expectLater(
        request('nope'),
        _failsWith(
          AuthFailure.invalidInput,
          issue: ValidationIssue.emailInvalid,
        ),
      );
      await request(' a@b.co ');
      expect(repo.last['email'], 'a@b.co');
    });

    test('VerifyCode wants six digits', () async {
      await expectLater(
        verify(email: 'a@b.co', code: '123'),
        _failsWith(
          AuthFailure.invalidInput,
          issue: ValidationIssue.codeIncomplete,
        ),
      );
      final ResetGrant grant = await verify(email: 'a@b.co', code: '123456');
      expect(grant.token, 'grant');
    });

    test('ResetPassword validates the password and the confirmation', () async {
      await expectLater(
        reset(
          grant: const ResetGrant('g'),
          password: 'abc',
          confirmation: 'abc',
        ),
        _failsWith(
          AuthFailure.invalidInput,
          issue: ValidationIssue.passwordTooShort,
        ),
      );
      await expectLater(
        reset(
          grant: const ResetGrant('g'),
          password: 'Abcdefg1',
          confirmation: 'x',
        ),
        _failsWith(
          AuthFailure.invalidInput,
          issue: ValidationIssue.confirmationMismatch,
        ),
      );
      expect(repo.calls, isEmpty);
      await reset(
        grant: const ResetGrant('g'),
        password: 'Abcdefg1',
        confirmation: 'Abcdefg1',
      );
      expect(repo.calls, <String>['reset']);
    });

    test('SignOut swallows a failing server', () async {
      repo.error = const AuthException(AuthFailure.network);
      await SignOut(repo)();
      expect(repo.calls, <String>['signOut']);
    });

    test(
      'SignInWithProvider returns null when the sheet is cancelled',
      () async {
        final SignInWithProvider cancelled = SignInWithProvider(
          repo,
          (SocialProvider p) async => null,
        );
        expect(await cancelled(SocialProvider.google), isNull);
        expect(repo.calls, isEmpty);
      },
    );

    test('SignInWithProvider sends the token it was given', () async {
      final SignInWithProvider useCase = SignInWithProvider(
        repo,
        (SocialProvider p) async => 'id-token-${p.id}',
      );
      final Session? session = await useCase(SocialProvider.apple);
      expect(session, isNotNull);
      expect(repo.last, <String, Object?>{
        'provider': SocialProvider.apple,
        'idToken': 'id-token-apple',
      });
    });

    test(
      'SignInWithProvider reports a failing SDK as a network failure',
      () async {
        final SignInWithProvider broken = SignInWithProvider(
          repo,
          (SocialProvider p) async => throw StateError('no play services'),
        );
        await expectLater(
          broken(SocialProvider.google),
          _failsWith(AuthFailure.network),
        );
      },
    );
  });

  group('AuthRepositoryImpl', () {
    AuthRepositoryImpl repoFor(
      Future<Map<String, Object?>> Function() respond,
    ) => AuthRepositoryImpl(_ScriptedDataSource(respond));

    test('maps a dropped connection to network', () async {
      final AuthRepository r = repoFor(() async => throw Exception('socket'));
      await expectLater(
        r.signIn(email: 'a@b.co', password: 'x', remember: false),
        _failsWith(AuthFailure.network),
      );
    });

    test('maps a malformed body to unknown', () async {
      final AuthRepository r = repoFor(
        () async => <String, Object?>{'user': 5},
      );
      await expectLater(
        r.signIn(email: 'a@b.co', password: 'x', remember: false),
        _failsWith(AuthFailure.unknown),
      );
    });

    test('keeps the details of a server error', () async {
      final AuthRepository r = repoFor(
        () async => <String, Object?>{
          'error': <String, Object?>{
            'code': 'rate_limited',
            'retryAfterSeconds': 12,
          },
        },
      );
      await expectLater(
        r.signIn(email: 'a@b.co', password: 'x', remember: false),
        throwsA(
          isA<AuthException>().having(
            (AuthException e) => e.retryAfter,
            'retryAfter',
            const Duration(seconds: 12),
          ),
        ),
      );
    });

    test('every call surfaces an error envelope', () async {
      final AuthRepository r = repoFor(
        () async => <String, Object?>{
          'error': <String, Object?>{'code': 'code_expired'},
        },
      );
      await expectLater(
        r.requestPasswordReset('a@b.co'),
        _failsWith(AuthFailure.codeExpired),
      );
      await expectLater(
        r.verifyCode(email: 'a@b.co', code: '123456'),
        _failsWith(AuthFailure.codeExpired),
      );
      await expectLater(
        r.resetPassword(grant: const ResetGrant('g'), password: 'x'),
        _failsWith(AuthFailure.codeExpired),
      );
      await expectLater(r.signOut(), _failsWith(AuthFailure.codeExpired));
      await expectLater(
        r.signUp(name: 'a', email: 'a@b.co', password: 'x'),
        _failsWith(AuthFailure.codeExpired),
      );
      await expectLater(
        r.signInWithProvider(provider: SocialProvider.google, idToken: 'x'),
        _failsWith(AuthFailure.codeExpired),
      );
    });
  });

  group('InMemoryAuthRemoteDataSource through the repository', () {
    late FakeClock clock;
    late AuthRepositoryImpl repo;

    setUp(() {
      clock = FakeClock();
      repo = AuthRepositoryImpl(
        InMemoryAuthRemoteDataSource(latency: Duration.zero, clock: clock.call),
        clock: clock.call,
      );
    });

    Future<Session> signInAda([String password = DemoAccount.password]) => repo
        .signIn(email: DemoAccount.email, password: password, remember: false);

    test('the seeded user signs in, with any casing of the email', () async {
      final Session s = await repo.signIn(
        email: ' ADA@Example.com ',
        password: DemoAccount.password,
        remember: false,
      );
      expect(s.account.name, DemoAccount.name);
      expect(s.account.email, DemoAccount.email);
      expect(s.accessToken, isNotEmpty);
      expect(s.refreshToken, isNotEmpty);
      expect(s.expiresAt, clock().add(AuthPolicy.sessionLifetime));
    });

    test('remember me lengthens the session', () async {
      final Session s = await repo.signIn(
        email: DemoAccount.email,
        password: DemoAccount.password,
        remember: true,
      );
      expect(s.remembered, isTrue);
      expect(s.expiresAt, clock().add(AuthPolicy.rememberedSessionLifetime));
    });

    test('a wrong password and an unknown email look the same', () async {
      await expectLater(
        signInAda('wrong'),
        _failsWith(AuthFailure.invalidCredentials),
      );
      await expectLater(
        repo.signIn(
          email: 'nobody@example.com',
          password: 'x',
          remember: false,
        ),
        _failsWith(AuthFailure.invalidCredentials),
      );
    });

    test('five wrong passwords lock sign-in, even for the right one', () async {
      for (int i = 0; i < 4; i++) {
        await expectLater(
          signInAda('wrong'),
          _failsWith(AuthFailure.invalidCredentials),
        );
      }
      await expectLater(
        signInAda('wrong'),
        throwsA(
          isA<AuthException>()
              .having(
                (AuthException e) => e.failure,
                'failure',
                AuthFailure.rateLimited,
              )
              .having(
                (AuthException e) => e.retryAfter,
                'retryAfter',
                AuthPolicy.signInLockout,
              ),
        ),
      );
      clock.advance(const Duration(seconds: 10));
      await expectLater(
        signInAda(),
        throwsA(
          isA<AuthException>().having(
            (AuthException e) => e.retryAfter,
            'retryAfter',
            const Duration(seconds: 20),
          ),
        ),
      );
      clock.advance(const Duration(seconds: 20));
      expect((await signInAda()).account.email, DemoAccount.email);
    });

    test(
      'unknown emails are limited too, so the lockout leaks nothing',
      () async {
        for (int i = 0; i < 4; i++) {
          await expectLater(
            repo.signIn(
              email: 'ghost@example.com',
              password: 'x',
              remember: false,
            ),
            _failsWith(AuthFailure.invalidCredentials),
          );
        }
        await expectLater(
          repo.signIn(
            email: 'ghost@example.com',
            password: 'x',
            remember: false,
          ),
          _failsWith(AuthFailure.rateLimited),
        );
      },
    );

    test('a success clears the failure count', () async {
      for (int i = 0; i < 4; i++) {
        await expectLater(
          signInAda('wrong'),
          _failsWith(AuthFailure.invalidCredentials),
        );
      }
      await signInAda();
      for (int i = 0; i < 4; i++) {
        await expectLater(
          signInAda('wrong'),
          _failsWith(AuthFailure.invalidCredentials),
        );
      }
    });

    test('sign up creates an account that can sign in', () async {
      final Session s = await repo.signUp(
        name: 'Grace Hopper',
        email: 'grace@example.com',
        password: 'Compile-r-1',
      );
      expect(s.account.initials, 'GH');
      expect(
        (await repo.signIn(
          email: 'GRACE@example.com',
          password: 'Compile-r-1',
          remember: false,
        )).account.name,
        'Grace Hopper',
      );
    });

    test('sign up refuses a taken email, whatever its casing', () async {
      await expectLater(
        repo.signUp(
          name: 'Ada',
          email: 'Ada@Example.com',
          password: 'Cairn-demo-1',
        ),
        _failsWith(AuthFailure.emailTaken),
      );
    });

    test(
      'a reset request answers identically for known and unknown emails',
      () async {
        final InMemoryAuthRemoteDataSource source =
            InMemoryAuthRemoteDataSource(latency: Duration.zero);
        expect(
          await source.requestPasswordReset(email: DemoAccount.email),
          await source.requestPasswordReset(email: 'nobody@example.com'),
        );
      },
    );

    test('the code is checked, with the attempts left counting down', () async {
      await repo.requestPasswordReset(DemoAccount.email);
      for (int left = 4; left >= 1; left--) {
        await expectLater(
          repo.verifyCode(email: DemoAccount.email, code: '000000'),
          throwsA(
            isA<AuthException>()
                .having(
                  (AuthException e) => e.failure,
                  'failure',
                  AuthFailure.invalidCode,
                )
                .having((AuthException e) => e.attemptsRemaining, 'left', left),
          ),
        );
      }
      await expectLater(
        repo.verifyCode(email: DemoAccount.email, code: '000000'),
        _failsWith(AuthFailure.tooManyAttempts),
      );
      await expectLater(
        repo.verifyCode(email: DemoAccount.email, code: DemoAccount.code),
        _failsWith(AuthFailure.tooManyAttempts),
      );
    });

    test('requesting a new code lifts the code lock', () async {
      await repo.requestPasswordReset(DemoAccount.email);
      for (int i = 0; i < 5; i++) {
        await expectLater(
          repo.verifyCode(email: DemoAccount.email, code: '000000'),
          throwsA(isA<AuthException>()),
        );
      }
      await repo.requestPasswordReset(DemoAccount.email);
      expect(
        (await repo.verifyCode(
          email: DemoAccount.email,
          code: DemoAccount.code,
        )).token,
        isNotEmpty,
      );
    });

    test('a code is useless before one was requested', () async {
      await expectLater(
        repo.verifyCode(email: DemoAccount.email, code: DemoAccount.code),
        _failsWith(AuthFailure.invalidCode),
      );
    });

    test('a code expires', () async {
      await repo.requestPasswordReset(DemoAccount.email);
      clock.advance(AuthPolicy.codeLifetime + const Duration(seconds: 1));
      await expectLater(
        repo.verifyCode(email: DemoAccount.email, code: DemoAccount.code),
        _failsWith(AuthFailure.codeExpired),
      );
    });

    test('a verified code lets the password be reset, once', () async {
      await repo.requestPasswordReset(DemoAccount.email);
      final ResetGrant grant = await repo.verifyCode(
        email: DemoAccount.email,
        code: DemoAccount.code,
      );
      await repo.resetPassword(grant: grant, password: 'Brand-new-2');
      await expectLater(
        signInAda(),
        _failsWith(AuthFailure.invalidCredentials),
      );
      expect((await signInAda('Brand-new-2')).account.email, DemoAccount.email);
      await expectLater(
        repo.resetPassword(grant: grant, password: 'Another-3'),
        _failsWith(AuthFailure.codeExpired),
      );
    });

    test('resetting a password lifts a sign-in lockout', () async {
      for (int i = 0; i < 5; i++) {
        await expectLater(signInAda('wrong'), throwsA(isA<AuthException>()));
      }
      await repo.requestPasswordReset(DemoAccount.email);
      final ResetGrant grant = await repo.verifyCode(
        email: DemoAccount.email,
        code: DemoAccount.code,
      );
      await repo.resetPassword(grant: grant, password: 'Brand-new-2');
      expect((await signInAda('Brand-new-2')).account.email, DemoAccount.email);
    });

    test(
      'an unknown address goes through the same steps without changing anything',
      () async {
        await repo.requestPasswordReset('ghost@example.com');
        final ResetGrant grant = await repo.verifyCode(
          email: 'ghost@example.com',
          code: DemoAccount.code,
        );
        await repo.resetPassword(grant: grant, password: 'Brand-new-2');
        await expectLater(
          repo.signIn(
            email: 'ghost@example.com',
            password: 'Brand-new-2',
            remember: false,
          ),
          _failsWith(AuthFailure.invalidCredentials),
        );
      },
    );

    test('social sign-in and sign-out answer', () async {
      final Session s = await repo.signInWithProvider(
        provider: SocialProvider.google,
        idToken: 'token',
      );
      expect(s.account.id, 'social-google');
      await repo.signOut();
    });

    test('latency delays every call by that long', () async {
      final InMemoryAuthRemoteDataSource slow = InMemoryAuthRemoteDataSource();
      expect(slow.latency, const Duration(milliseconds: 700));
    });
  });
}
