import '../models/footer_content.dart';
import '../repositories/footer_repository.dart';

/// Loads the footer section's content.
class GetFooter {
  /// Creates the use case.
  const GetFooter(this._repository);

  final FooterRepository _repository;

  /// Runs the use case.
  Future<FooterContent> call() => _repository.getFooter();
}
