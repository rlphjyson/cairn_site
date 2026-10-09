import '../models/features_content.dart';

/// Where the features content comes from.
abstract interface class FeaturesRepository {
  /// The section content.
  Future<FeaturesContent> getFeatures();
}
