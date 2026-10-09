import '../../../common/constants/content_sections.dart';
import '../../../domain/faq/mappers/faq_mapper.dart';
import '../../../domain/faq/models/faq_content.dart';
import '../../../domain/faq/repositories/faq_repository.dart';
import '../../content/remote/app_content_data_source.dart';

/// Reads the faq content from the content data source and maps it.
class FaqRepositoryImpl implements FaqRepository {
  /// Creates the repository.
  const FaqRepositoryImpl(this._content);

  final AppContentDataSource _content;

  @override
  Future<FaqContent> getFaq() async =>
      mapFaq(await _content.fetchSection(ContentSections.faq));
}
