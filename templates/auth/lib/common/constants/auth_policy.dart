/// The rules every screen and the in-memory server agree on.
///
/// Change a number here and the validators, the checklists, the cooldowns and
/// the in-memory server all follow. A real backend enforces its own copy of
/// these rules; keep the two in step.
abstract final class AuthPolicy {
  /// The fewest characters a password may have.
  static const int minPasswordLength = 8;

  /// From this length a password earns a strength point on its own.
  static const int longPasswordLength = 12;

  /// Wrong passwords tolerated for one email before sign-in is locked.
  static const int maxSignInAttempts = 5;

  /// How long sign-in stays locked after [maxSignInAttempts] failures.
  static const Duration signInLockout = Duration(seconds: 30);

  /// Digits in a verification code.
  static const int codeLength = 6;

  /// Wrong codes tolerated before the code is locked and a new one is needed.
  static const int maxCodeAttempts = 5;

  /// How long a verification code stays valid.
  static const Duration codeLifetime = Duration(minutes: 10);

  /// How long before a code may be requested again.
  static const Duration resendCooldown = Duration(seconds: 30);

  /// The fewest characters a display name may have.
  static const int minNameLength = 2;

  /// How long a session lasts when "Remember me" is off.
  static const Duration sessionLifetime = Duration(hours: 1);

  /// How long a session lasts when "Remember me" is on.
  static const Duration rememberedSessionLifetime = Duration(days: 30);

  /// Passwords that are never accepted, however they score. Lower case.
  static const Set<String> commonPasswords = <String>{
    'password',
    'password1',
    'password123',
    'passw0rd',
    'qwertyui',
    'qwerty123',
    'letmein1',
    'welcome1',
    'welcome123',
    '12345678',
    '123456789',
    '1234567890',
    'iloveyou',
    'admin123',
    'abc12345',
    'changeme',
  };
}
