import '../models/site_info.dart';
import '../repositories/site_repository.dart';

/// Loads the site content.
class GetSiteInfo {
  /// Creates the use case.
  const GetSiteInfo(this._repository);

  final SiteRepository _repository;

  /// Runs the use case.
  Future<SiteInfo> call() => _repository.getSiteInfo();
}
