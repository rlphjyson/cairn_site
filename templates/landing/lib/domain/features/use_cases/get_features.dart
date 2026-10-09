import '../models/features_content.dart';
import '../repositories/features_repository.dart';

/// Loads the features section's content.
class GetFeatures {
  /// Creates the use case.
  const GetFeatures(this._repository);

  final FeaturesRepository _repository;

  /// Runs the use case.
  Future<FeaturesContent> call() => _repository.getFeatures();
}
