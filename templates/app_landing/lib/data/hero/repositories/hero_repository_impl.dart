import '../../../common/constants/content_sections.dart';
import '../../../domain/hero/mappers/hero_mapper.dart';
import '../../../domain/hero/models/hero_content.dart';
import '../../../domain/hero/repositories/hero_repository.dart';
import '../../content/remote/app_content_data_source.dart';

/// Reads the hero content from the content data source and maps it.
class HeroRepositoryImpl implements HeroRepository {
  /// Creates the repository.
  const HeroRepositoryImpl(this._content);

  final AppContentDataSource _content;

  @override
  Future<HeroContent> getHero() async =>
      mapHero(await _content.fetchSection(ContentSections.hero));
}
