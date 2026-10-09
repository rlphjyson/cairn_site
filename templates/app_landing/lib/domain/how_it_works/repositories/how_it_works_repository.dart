import '../models/how_it_works_content.dart';

/// Where the how it works section's content comes from.
abstract interface class HowItWorksRepository {
  /// The section's content.
  Future<HowItWorksContent> getHowItWorks();
}
