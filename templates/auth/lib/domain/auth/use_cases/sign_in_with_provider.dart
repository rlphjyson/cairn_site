import '../models/auth_failure.dart';
import '../models/session.dart';
import '../models/social_provider.dart';
import '../repositories/auth_repository.dart';

/// Signs in with Google or Apple.
///
/// Asks the host's [SocialIdTokenProvider] (your `google_sign_in` or
/// `sign_in_with_apple` code) for an identity token, then hands it to the
/// server. Returns `null` when the person cancelled the provider's sheet,
/// which is not an error.
class SignInWithProvider {
  /// Creates the use case.
  const SignInWithProvider(this._repository, this._idToken);

  final AuthRepository _repository;
  final SocialIdTokenProvider _idToken;

  /// Runs it.
  Future<Session?> call(SocialProvider provider) async {
    final String? token;
    try {
      token = await _idToken(provider);
    } on Object {
      // The provider's SDK failed (no network, no Play Services...).
      throw const AuthException(AuthFailure.network);
    }
    if (token == null || token.isEmpty) return null;
    return _repository.signInWithProvider(provider: provider, idToken: token);
  }
}
