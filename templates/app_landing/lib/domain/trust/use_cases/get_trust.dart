import '../models/trust_content.dart';
import '../repositories/trust_repository.dart';

/// Loads the trust content.
class GetTrust {
  /// Creates the use case.
  const GetTrust(this._repository);

  final TrustRepository _repository;

  /// Runs the use case.
  Future<TrustContent> call() => _repository.getTrust();
}
