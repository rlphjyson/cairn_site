import '../models/subscribe_result.dart';

/// Where newsletter subscriptions go.
abstract interface class NewsletterRepository {
  /// Subscribes [email]. Throws [NewsletterException] if the service refuses
  /// or cannot be reached.
  Future<SubscribeResult> subscribe(String email);
}
