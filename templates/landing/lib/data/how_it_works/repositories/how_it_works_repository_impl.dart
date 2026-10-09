import '../../../domain/how_it_works/mappers/how_it_works_mapper.dart';
import '../../../domain/how_it_works/models/how_it_works_content.dart';
import '../../../domain/how_it_works/repositories/how_it_works_repository.dart';
import '../remote/how_it_works_remote_data_source.dart';

/// Reads how it works content from a remote data source and maps it.
class HowItWorksRepositoryImpl implements HowItWorksRepository {
  /// Creates the repository.
  const HowItWorksRepositoryImpl(this._remote);

  final HowItWorksRemoteDataSource _remote;

  @override
  Future<HowItWorksContent> getHowItWorks() async =>
      mapHowItWorks(await _remote.fetchHowItWorks());
}
