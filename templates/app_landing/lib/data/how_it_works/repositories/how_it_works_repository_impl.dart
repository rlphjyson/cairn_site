import '../../../common/constants/content_sections.dart';
import '../../../domain/how_it_works/mappers/how_it_works_mapper.dart';
import '../../../domain/how_it_works/models/how_it_works_content.dart';
import '../../../domain/how_it_works/repositories/how_it_works_repository.dart';
import '../../content/remote/app_content_data_source.dart';

/// Reads the how_it_works content from the content data source and maps it.
class HowItWorksRepositoryImpl implements HowItWorksRepository {
  /// Creates the repository.
  const HowItWorksRepositoryImpl(this._content);

  final AppContentDataSource _content;

  @override
  Future<HowItWorksContent> getHowItWorks() async =>
      mapHowItWorks(await _content.fetchSection(ContentSections.howItWorks));
}
