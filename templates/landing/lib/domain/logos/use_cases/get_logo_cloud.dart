import '../models/logo_cloud.dart';
import '../repositories/logos_repository.dart';

/// Loads the logos section's content.
class GetLogoCloud {
  /// Creates the use case.
  const GetLogoCloud(this._repository);

  final LogosRepository _repository;

  /// Runs the use case.
  Future<LogoCloud> call() => _repository.getLogoCloud();
}
