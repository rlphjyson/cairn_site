/// The backend, as decoded JSON.
///
/// **This is the place to connect a real server.** Implement this interface
/// with `package:http`, `dio` or an SDK such as Firebase Auth, register it in
/// `createAuthLocator` (or pass it to `AuthApp(authDataSource: ...)`) and
/// nothing else changes. Every method returns the decoded response body; a
/// failure is either a thrown network error or a body with an `error`
/// envelope. `AuthMapper` documents both shapes.
abstract interface class AuthRemoteDataSource {
  /// Signs in with an email and password. Returns a session body.
  Future<Map<String, Object?>> signIn({
    required String email,
    required String password,
    required bool remember,
  });

  /// Creates an account and returns a session body.
  Future<Map<String, Object?>> signUp({
    required String name,
    required String email,
    required String password,
  });

  /// Exchanges a provider's identity token for a session body. [provider] is
  /// `google` or `apple`.
  Future<Map<String, Object?>> signInWithProvider({
    required String provider,
    required String idToken,
  });

  /// Emails a verification code if an account exists. Must return the same
  /// body whether or not it does.
  Future<Map<String, Object?>> requestPasswordReset({required String email});

  /// Checks a code. Returns a body with a `resetToken`.
  Future<Map<String, Object?>> verifyCode({
    required String email,
    required String code,
  });

  /// Sets a new password using a `resetToken`.
  Future<Map<String, Object?>> resetPassword({
    required String resetToken,
    required String password,
  });

  /// Revokes the session.
  Future<Map<String, Object?>> signOut();
}
