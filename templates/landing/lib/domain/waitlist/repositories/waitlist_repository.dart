import '../models/join_outcome.dart';
import '../models/waitlist_content.dart';

/// The waitlist: its copy, and the signup itself.
abstract interface class WaitlistRepository {
  /// The section copy.
  Future<WaitlistContent> getWaitlist();

  /// Adds [email] to the waitlist.
  ///
  /// Throws a [WaitlistException] when the service refuses.
  Future<WaitlistReceipt> join(String email);
}
