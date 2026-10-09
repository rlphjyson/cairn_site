import '../../../domain/stats/mappers/stats_mapper.dart';
import '../../../domain/stats/models/stats_content.dart';
import '../../../domain/stats/repositories/stats_repository.dart';
import '../remote/stats_remote_data_source.dart';

/// Reads stats content from a remote data source and maps it.
class StatsRepositoryImpl implements StatsRepository {
  /// Creates the repository.
  const StatsRepositoryImpl(this._remote);

  final StatsRemoteDataSource _remote;

  @override
  Future<StatsContent> getStats() async => mapStats(await _remote.fetchStats());
}
