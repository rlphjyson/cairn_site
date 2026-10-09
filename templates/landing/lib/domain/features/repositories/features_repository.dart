import '../models/features_content.dart';

/// Where the features section's content comes from.
abstract interface class FeaturesRepository {
  /// The section's content.
  Future<FeaturesContent> getFeatures();
}
