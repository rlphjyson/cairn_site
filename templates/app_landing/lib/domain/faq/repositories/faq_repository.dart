import '../models/faq_content.dart';

/// Where the faq section's content comes from.
abstract interface class FaqRepository {
  /// The section's content.
  Future<FaqContent> getFaq();
}
