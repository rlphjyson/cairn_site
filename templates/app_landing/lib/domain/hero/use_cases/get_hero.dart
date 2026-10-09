import '../models/hero_content.dart';
import '../repositories/hero_repository.dart';

/// Loads the hero content.
class GetHero {
  /// Creates the use case.
  const GetHero(this._repository);

  final HeroRepository _repository;

  /// Runs the use case.
  Future<HeroContent> call() => _repository.getHero();
}
