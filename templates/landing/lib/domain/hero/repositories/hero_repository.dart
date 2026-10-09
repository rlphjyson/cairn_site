import '../models/hero_content.dart';

/// Where the hero section's content comes from.
abstract interface class HeroRepository {
  /// The section's content.
  Future<HeroContent> getHero();
}
