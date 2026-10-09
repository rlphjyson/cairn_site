import '../../../common/constants/content_sections.dart';
import '../../../domain/site/mappers/site_mapper.dart';
import '../../../domain/site/models/site_info.dart';
import '../../../domain/site/repositories/site_repository.dart';
import '../../content/remote/app_content_data_source.dart';

/// Reads the site content from the content data source and maps it.
class SiteRepositoryImpl implements SiteRepository {
  /// Creates the repository.
  const SiteRepositoryImpl(this._content);

  final AppContentDataSource _content;

  @override
  Future<SiteInfo> getSiteInfo() async =>
      mapSiteInfo(await _content.fetchSection(ContentSections.site));
}
