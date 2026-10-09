/// A third-party identity provider the welcome screen can offer.
enum SocialProvider {
  /// "Continue with Google".
  google('google', 'Google'),

  /// "Continue with Apple".
  apple('apple', 'Apple');

  const SocialProvider(this.id, this.label);

  /// The id sent to the server.
  final String id;

  /// The name shown on the button.
  final String label;
}

/// Gets an identity token from a provider's own sign-in SDK.
///
/// This is the wiring point for `google_sign_in` and `sign_in_with_apple`: run
/// the SDK's flow and return the ID token it gives you, or `null` when the
/// person cancelled. The template sends the token to your server, which
/// verifies it with the provider and returns a session.
typedef SocialIdTokenProvider =
    Future<String?> Function(SocialProvider provider);
