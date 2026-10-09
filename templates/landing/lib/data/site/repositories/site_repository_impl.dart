import '../../../domain/site/mappers/site_mapper.dart';
import '../../../domain/site/models/site_info.dart';
import '../../../domain/site/repositories/site_repository.dart';
import '../remote/site_remote_data_source.dart';

/// Reads site content from a remote data source and maps it.
class SiteRepositoryImpl implements SiteRepository {
  /// Creates the repository.
  const SiteRepositoryImpl(this._remote);

  final SiteRemoteDataSource _remote;

  @override
  Future<SiteInfo> getSiteInfo() async =>
      mapSiteInfo(await _remote.fetchSiteInfo());
}
