import '../models/faq_content.dart';
import '../repositories/faq_repository.dart';

/// Loads the faq section's content.
class GetFaq {
  /// Creates the use case.
  const GetFaq(this._repository);

  final FaqRepository _repository;

  /// Runs the use case.
  Future<FaqContent> call() => _repository.getFaq();
}
