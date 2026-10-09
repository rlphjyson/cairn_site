/// Where newsletter subscriptions are sent.
///
/// Implement it against Mailchimp, Buttondown, your own endpoint, etc. and
/// register it in `core/infrastructure/di/blog_injection.dart` in place of
/// [InMemoryNewsletterRemoteDataSource]. Return `{"status": "subscribed"}`,
/// `{"status": "already_subscribed"}` or `{"error": "message"}`.
abstract interface class NewsletterRemoteDataSource {
  /// Sends [email] to the service and returns its decoded answer.
  Future<Map<String, Object?>> subscribe(String email);
}

/// Pretends to be a newsletter service so the form can be tried out.
///
/// * addresses ending in `@error.test` fail with a service error;
/// * an address that was already subscribed in this session is reported as
///   already subscribed;
/// * anything else succeeds after [latency].
class InMemoryNewsletterRemoteDataSource implements NewsletterRemoteDataSource {
  /// Creates the source.
  InMemoryNewsletterRemoteDataSource({
    this.latency = const Duration(milliseconds: 600),
  });

  /// How long a request takes.
  final Duration latency;

  final Set<String> _subscribed = <String>{};

  @override
  Future<Map<String, Object?>> subscribe(String email) async {
    await Future<void>.delayed(latency);
    final String key = email.toLowerCase();
    if (key.endsWith('@error.test')) {
      return <String, Object?>{
        'error': 'We could not reach the newsletter service. Try again soon.',
      };
    }
    final bool added = _subscribed.add(key);
    return <String, Object?>{
      'status': added ? 'subscribed' : 'already_subscribed',
    };
  }
}
