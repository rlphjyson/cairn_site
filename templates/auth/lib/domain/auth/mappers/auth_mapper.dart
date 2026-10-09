import '../models/account.dart';
import '../models/auth_failure.dart';
import '../models/reset_grant.dart';
import '../models/session.dart';

/// Converts the backend's decoded JSON to models, and its error envelope to an
/// [AuthException].
///
/// This is the only place that knows the wire format. The shapes are:
///
/// ```json
/// // a session (sign in, sign up, social sign in)
/// { "user": { "id": "u_1", "name": "Ada Lovelace", "email": "ada@example.com" },
///   "accessToken": "opaque-token", "refreshToken": "opaque-token",
///   "expiresIn": 3600 }
///
/// // a reset grant (verify code)
/// { "resetToken": "opaque-token" }
///
/// // any failure (a non-2xx body decodes to the same shape)
/// { "error": { "code": "rate_limited", "retryAfterSeconds": 30 } }
/// ```
abstract final class AuthMapper {
  /// Throws the [AuthException] described by [json] when it carries an
  /// `error`; returns normally otherwise.
  static void throwIfError(Map<String, Object?> json) {
    final Object? error = json['error'];
    if (error is! Map<String, Object?>) return;
    final int? retry = (error['retryAfterSeconds'] as num?)?.toInt();
    throw AuthException(
      failureFromCode(error['code'] as String?),
      retryAfter: retry == null ? null : Duration(seconds: retry),
      attemptsRemaining: (error['attemptsRemaining'] as num?)?.toInt(),
    );
  }

  /// The [AuthFailure] for a server error [code].
  static AuthFailure failureFromCode(String? code) => switch (code) {
    'invalid_credentials' => AuthFailure.invalidCredentials,
    'email_taken' => AuthFailure.emailTaken,
    'rate_limited' => AuthFailure.rateLimited,
    'invalid_code' => AuthFailure.invalidCode,
    'code_expired' => AuthFailure.codeExpired,
    'too_many_attempts' => AuthFailure.tooManyAttempts,
    _ => AuthFailure.unknown,
  };

  /// Maps a user object to an [Account].
  static Account accountFromJson(Map<String, Object?> json) => Account(
    id: json['id']! as String,
    name: (json['name'] as String?) ?? '',
    email: json['email']! as String,
  );

  /// Maps a session response. [now] stamps the expiry; [remembered] records
  /// whether the person asked to stay signed in.
  static Session sessionFromJson(
    Map<String, Object?> json, {
    required DateTime now,
    bool remembered = false,
  }) {
    throwIfError(json);
    final int? expiresIn = (json['expiresIn'] as num?)?.toInt();
    return Session(
      account: accountFromJson(json['user']! as Map<String, Object?>),
      accessToken: json['accessToken']! as String,
      refreshToken: json['refreshToken'] as String?,
      expiresAt: expiresIn == null
          ? null
          : now.add(Duration(seconds: expiresIn)),
      remembered: remembered,
    );
  }

  /// Maps a verify-code response to a [ResetGrant].
  static ResetGrant resetGrantFromJson(Map<String, Object?> json) {
    throwIfError(json);
    return ResetGrant(json['resetToken']! as String);
  }
}
