import '../../../domain/hero/mappers/hero_mapper.dart';
import '../../../domain/hero/models/hero_content.dart';
import '../../../domain/hero/repositories/hero_repository.dart';
import '../remote/hero_remote_data_source.dart';

/// Reads hero content from a remote data source and maps it.
class HeroRepositoryImpl implements HeroRepository {
  /// Creates the repository.
  const HeroRepositoryImpl(this._remote);

  final HeroRemoteDataSource _remote;

  @override
  Future<HeroContent> getHero() async => mapHero(await _remote.fetchHero());
}
