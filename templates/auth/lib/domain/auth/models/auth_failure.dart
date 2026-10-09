import '../../validation/models/validation_issue.dart';

/// Everything that can go wrong talking to the backend, as the screens see it.
enum AuthFailure {
  /// Wrong email or password. Never says which.
  invalidCredentials,

  /// An account with that email already exists.
  emailTaken,

  /// Too many sign-in attempts; try again after a delay.
  rateLimited,

  /// The verification code is wrong.
  invalidCode,

  /// The code or reset session has expired.
  codeExpired,

  /// Too many wrong codes; a new code is needed.
  tooManyAttempts,

  /// The input failed validation before it was sent.
  invalidInput,

  /// The server could not be reached.
  network,

  /// Anything else.
  unknown,
}

/// A failed auth call.
///
/// Thrown by the repository and use cases, caught by cubits. Carries no
/// credentials.
class AuthException implements Exception {
  /// Creates an exception.
  const AuthException(
    this.failure, {
    this.retryAfter,
    this.attemptsRemaining,
    this.issue,
  });

  /// What went wrong.
  final AuthFailure failure;

  /// How long to wait before trying again, for [AuthFailure.rateLimited].
  final Duration? retryAfter;

  /// Wrong guesses left, for [AuthFailure.invalidCode].
  final int? attemptsRemaining;

  /// The field issue, for [AuthFailure.invalidInput].
  final ValidationIssue? issue;

  /// Turns anything thrown into an [AuthException] so a cubit always has a
  /// failure to show.
  static AuthException from(Object error) =>
      error is AuthException ? error : const AuthException(AuthFailure.unknown);

  @override
  String toString() => 'AuthException($failure)';
}
