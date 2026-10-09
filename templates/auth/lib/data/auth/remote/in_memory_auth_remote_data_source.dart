import '../../../common/constants/auth_policy.dart';
import '../../../common/constants/demo_account.dart';
import '../../../common/utils/attempt_limiter.dart';
import '../../../common/utils/clock.dart';
import 'auth_remote_data_source.dart';

/// A stand-in server that keeps everything in memory.
///
/// It behaves like a careful backend so the screens can be developed and
/// tested without one:
///
/// * a seeded user, `ada@example.com` with `Cairn-demo-1`;
/// * five wrong passwords for one email (known or not) lock sign-in for
///   [AuthPolicy.signInLockout], answering `rate_limited` with the seconds left;
/// * a password reset always answers "accepted", then accepts the code
///   [DemoAccount.code] for [AuthPolicy.codeLifetime]; five wrong codes lock
///   the code until a new one is requested;
/// * a reset token works once.
///
/// **This is a demo.** It stores passwords as plain text because it is a
/// throwaway map in memory; a real server stores a salted hash from a slow
/// algorithm (Argon2id, scrypt or bcrypt) and never the password itself.
class InMemoryAuthRemoteDataSource implements AuthRemoteDataSource {
  /// Creates the server.
  ///
  /// [latency] is how long each call takes, so loading states show; pass
  /// [Duration.zero] in tests. [clock] drives lockouts and code expiry.
  InMemoryAuthRemoteDataSource({
    this.latency = const Duration(milliseconds: 700),
    Clock clock = systemClock,
  }) : _clock = clock,
       _signInLimiter = AttemptLimiter(
         maxAttempts: AuthPolicy.maxSignInAttempts,
         lockout: AuthPolicy.signInLockout,
         clock: clock,
       ),
       _codeLimiter = AttemptLimiter(
         maxAttempts: AuthPolicy.maxCodeAttempts,
         lockout: AuthPolicy.codeLifetime,
         clock: clock,
       ) {
    _users[DemoAccount.email] = _User(
      id: DemoAccount.id,
      name: DemoAccount.name,
      email: DemoAccount.email,
      password: DemoAccount.password,
    );
  }

  /// How long every call takes.
  final Duration latency;

  final Clock _clock;
  final AttemptLimiter _signInLimiter;
  final AttemptLimiter _codeLimiter;
  final Map<String, _User> _users = <String, _User>{};
  final Map<String, DateTime> _codesIssuedAt = <String, DateTime>{};
  final Map<String, String> _resetTokens = <String, String>{};
  int _issued = 0;

  String _key(String email) => email.trim().toLowerCase();

  Future<void> _wait() async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
  }

  @override
  Future<Map<String, Object?>> signIn({
    required String email,
    required String password,
    required bool remember,
  }) async {
    await _wait();
    final String key = _key(email);
    final Duration? locked = _signInLimiter.lockedFor(key);
    if (locked != null) return _rateLimited(locked);

    final _User? user = _users[key];
    // Unknown emails count as failures too, and answer the same way as a wrong
    // password, so neither the message nor the lockout reveals who has an
    // account.
    if (user == null || user.password != password) {
      final Duration? lock = _signInLimiter.recordFailure(key);
      return lock != null ? _rateLimited(lock) : _error('invalid_credentials');
    }
    _signInLimiter.reset(key);
    return _session(user, remember: remember);
  }

  @override
  Future<Map<String, Object?>> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    await _wait();
    final String key = _key(email);
    if (_users.containsKey(key)) return _error('email_taken');
    final _User user = _User(
      id: 'user-${_users.length + 1}',
      name: name.trim(),
      email: email.trim(),
      password: password,
    );
    _users[key] = user;
    return _session(user);
  }

  @override
  Future<Map<String, Object?>> signInWithProvider({
    required String provider,
    required String idToken,
  }) async {
    await _wait();
    // A real server verifies [idToken] with the provider, then finds or
    // creates the account for the identity inside it.
    final _User user = _User(
      id: 'social-$provider',
      name: 'Taylor Rivera',
      email: 'taylor.rivera@example.com',
      password: '',
    );
    return _session(user);
  }

  @override
  Future<Map<String, Object?>> requestPasswordReset({
    required String email,
  }) async {
    await _wait();
    final String key = _key(email);
    // Every address gets a pending code, known or not, and the same answer.
    // A real server sends mail only when the account exists.
    _codesIssuedAt[key] = _clock();
    _codeLimiter.reset(key);
    return <String, Object?>{'accepted': true};
  }

  @override
  Future<Map<String, Object?>> verifyCode({
    required String email,
    required String code,
  }) async {
    await _wait();
    final String key = _key(email);
    final Duration? locked = _codeLimiter.lockedFor(key);
    if (locked != null) return _tooManyAttempts(locked);

    final DateTime? issuedAt = _codesIssuedAt[key];
    if (issuedAt != null &&
        _clock().difference(issuedAt) > AuthPolicy.codeLifetime) {
      return _error('code_expired');
    }
    if (issuedAt == null || code != DemoAccount.code) {
      final Duration? lock = _codeLimiter.recordFailure(key);
      if (lock != null) return _tooManyAttempts(lock);
      return _error(
        'invalid_code',
        attemptsRemaining: _codeLimiter.attemptsLeft(key),
      );
    }
    _codeLimiter.reset(key);
    _codesIssuedAt.remove(key);
    final String token = 'reset-${++_issued}';
    _resetTokens[token] = key;
    return <String, Object?>{'resetToken': token};
  }

  @override
  Future<Map<String, Object?>> resetPassword({
    required String resetToken,
    required String password,
  }) async {
    await _wait();
    final String? key = _resetTokens.remove(resetToken);
    if (key == null) return _error('code_expired');
    final _User? user = _users[key];
    // An unknown address gets the same success, for the same reason as above.
    if (user != null) user.password = password;
    _signInLimiter.reset(key);
    return <String, Object?>{'ok': true};
  }

  @override
  Future<Map<String, Object?>> signOut() async {
    await _wait();
    return <String, Object?>{'ok': true};
  }

  Map<String, Object?> _session(_User user, {bool remember = false}) {
    final Duration lifetime = remember
        ? AuthPolicy.rememberedSessionLifetime
        : AuthPolicy.sessionLifetime;
    return <String, Object?>{
      'user': <String, Object?>{
        'id': user.id,
        'name': user.name,
        'email': user.email,
      },
      'accessToken': 'demo-token-${++_issued}',
      'refreshToken': 'demo-refresh-${++_issued}',
      'expiresIn': lifetime.inSeconds,
    };
  }

  Map<String, Object?> _error(String code, {int? attemptsRemaining}) =>
      <String, Object?>{
        'error': <String, Object?>{
          'code': code,
          'attemptsRemaining': ?attemptsRemaining,
        },
      };

  Map<String, Object?> _rateLimited(Duration wait) => <String, Object?>{
    'error': <String, Object?>{
      'code': 'rate_limited',
      'retryAfterSeconds': _seconds(wait),
    },
  };

  Map<String, Object?> _tooManyAttempts(Duration wait) => <String, Object?>{
    'error': <String, Object?>{
      'code': 'too_many_attempts',
      'retryAfterSeconds': _seconds(wait),
    },
  };

  int _seconds(Duration d) => (d.inMilliseconds / 1000).ceil();
}

class _User {
  _User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
  });

  final String id;
  final String name;
  final String email;
  String password;
}
