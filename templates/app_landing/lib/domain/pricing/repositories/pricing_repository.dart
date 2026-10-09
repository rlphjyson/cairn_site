import '../models/pricing_content.dart';

/// Where the pricing section's content comes from.
abstract interface class PricingRepository {
  /// The section's content.
  Future<PricingContent> getPricing();
}
