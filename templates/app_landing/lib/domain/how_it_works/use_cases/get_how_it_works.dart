import '../models/how_it_works_content.dart';
import '../repositories/how_it_works_repository.dart';

/// Loads the how it works section's content.
class GetHowItWorks {
  /// Creates the use case.
  const GetHowItWorks(this._repository);

  final HowItWorksRepository _repository;

  /// Runs the use case.
  Future<HowItWorksContent> call() => _repository.getHowItWorks();
}
