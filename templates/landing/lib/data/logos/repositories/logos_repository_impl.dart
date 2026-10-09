import '../../../domain/logos/mappers/logos_mapper.dart';
import '../../../domain/logos/models/logo_cloud.dart';
import '../../../domain/logos/repositories/logos_repository.dart';
import '../remote/logos_remote_data_source.dart';

/// Reads logos content from a remote data source and maps it.
class LogosRepositoryImpl implements LogosRepository {
  /// Creates the repository.
  const LogosRepositoryImpl(this._remote);

  final LogosRemoteDataSource _remote;

  @override
  Future<LogoCloud> getLogoCloud() async =>
      mapLogoCloud(await _remote.fetchLogoCloud());
}
