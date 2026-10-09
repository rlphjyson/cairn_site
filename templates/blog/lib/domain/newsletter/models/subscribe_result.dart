/// The outcome of a successful subscription request.
enum SubscribeResult {
  /// The address is now on the list.
  subscribed,

  /// It already was; nothing changed.
  alreadySubscribed,
}

/// A subscription that did not go through. [message] is safe to show.
class NewsletterException implements Exception {
  /// Creates the exception.
  const NewsletterException(this.message);

  /// What went wrong, in words a reader can act on.
  final String message;

  @override
  String toString() => 'NewsletterException: $message';
}

/// The address is not a valid email.
class InvalidEmailException extends NewsletterException {
  /// Creates the exception.
  const InvalidEmailException(super.message);
}
