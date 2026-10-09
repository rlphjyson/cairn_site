import '../models/hero_content.dart';

/// Where the hero content comes from.
abstract interface class HeroRepository {
  /// The section content.
  Future<HeroContent> getHero();
}
