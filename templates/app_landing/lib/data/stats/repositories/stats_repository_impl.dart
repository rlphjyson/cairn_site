import '../../../common/constants/content_sections.dart';
import '../../../domain/stats/mappers/stats_mapper.dart';
import '../../../domain/stats/models/stats_content.dart';
import '../../../domain/stats/repositories/stats_repository.dart';
import '../../content/remote/app_content_data_source.dart';

/// Reads the stats content from the content data source and maps it.
class StatsRepositoryImpl implements StatsRepository {
  /// Creates the repository.
  const StatsRepositoryImpl(this._content);

  final AppContentDataSource _content;

  @override
  Future<StatsContent> getStats() async =>
      mapStats(await _content.fetchSection(ContentSections.stats));
}
