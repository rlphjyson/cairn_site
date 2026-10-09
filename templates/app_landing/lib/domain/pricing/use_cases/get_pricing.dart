import '../models/pricing_content.dart';
import '../repositories/pricing_repository.dart';

/// Loads the pricing section's content.
class GetPricing {
  /// Creates the use case.
  const GetPricing(this._repository);

  final PricingRepository _repository;

  /// Runs the use case.
  Future<PricingContent> call() => _repository.getPricing();
}
