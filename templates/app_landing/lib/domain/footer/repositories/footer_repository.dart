import '../models/footer_content.dart';

/// Where the footer section's content comes from.
abstract interface class FooterRepository {
  /// The section's content.
  Future<FooterContent> getFooter();
}
