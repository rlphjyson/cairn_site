import '../../../common/constants/content_sections.dart';
import '../../../domain/footer/mappers/footer_mapper.dart';
import '../../../domain/footer/models/footer_content.dart';
import '../../../domain/footer/repositories/footer_repository.dart';
import '../../content/remote/app_content_data_source.dart';

/// Reads the footer content from the content data source and maps it.
class FooterRepositoryImpl implements FooterRepository {
  /// Creates the repository.
  const FooterRepositoryImpl(this._content);

  final AppContentDataSource _content;

  @override
  Future<FooterContent> getFooter() async =>
      mapFooter(await _content.fetchSection(ContentSections.footer));
}
