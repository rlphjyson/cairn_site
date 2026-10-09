import '../models/subscribe_result.dart';

/// Remote JSON -> [SubscribeResult].
///
/// Expects `{"status": "subscribed"}` or `{"status": "already_subscribed"}`
/// and turns `{"error": "..."}` into a [NewsletterException].
abstract final class SubscribeResultMapper {
  /// Maps the response body.
  static SubscribeResult fromJson(Map<String, Object?> json) {
    final Object? error = json['error'];
    if (error is String && error.isNotEmpty) {
      throw NewsletterException(error);
    }
    return switch (json['status']) {
      'subscribed' => SubscribeResult.subscribed,
      'already_subscribed' => SubscribeResult.alreadySubscribed,
      _ => throw const NewsletterException(
        'The newsletter service sent an answer we could not read.',
      ),
    };
  }
}
