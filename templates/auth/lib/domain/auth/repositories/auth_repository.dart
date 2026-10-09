import '../models/reset_grant.dart';
import '../models/session.dart';
import '../models/social_provider.dart';

/// What the domain needs from an authentication backend.
///
/// Every method either completes or throws an `AuthException`.
abstract interface class AuthRepository {
  /// Signs in with an email and password.
  Future<Session> signIn({
    required String email,
    required String password,
    required bool remember,
  });

  /// Creates an account and signs it in.
  Future<Session> signUp({
    required String name,
    required String email,
    required String password,
  });

  /// Signs in with an identity token from [provider]'s SDK.
  Future<Session> signInWithProvider({
    required SocialProvider provider,
    required String idToken,
  });

  /// Sends a verification code to [email] if an account exists for it.
  ///
  /// Completes the same way whether or not the account exists, so the response
  /// cannot be used to discover who has an account.
  Future<void> requestPasswordReset(String email);

  /// Checks a code sent by [requestPasswordReset].
  Future<ResetGrant> verifyCode({required String email, required String code});

  /// Sets a new password using the grant from [verifyCode].
  Future<void> resetPassword({
    required ResetGrant grant,
    required String password,
  });

  /// Ends the session on the server.
  Future<void> signOut();
}
