import '../../../domain/features/mappers/features_mapper.dart';
import '../../../domain/features/models/features_content.dart';
import '../../../domain/features/repositories/features_repository.dart';
import '../remote/features_remote_data_source.dart';

/// Reads features content from a remote data source and maps it.
class FeaturesRepositoryImpl implements FeaturesRepository {
  /// Creates the repository.
  const FeaturesRepositoryImpl(this._remote);

  final FeaturesRemoteDataSource _remote;

  @override
  Future<FeaturesContent> getFeatures() async =>
      mapFeatures(await _remote.fetchFeatures());
}
