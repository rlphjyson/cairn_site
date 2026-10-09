import '../../../common/constants/content_sections.dart';
import '../../../domain/trust/mappers/trust_mapper.dart';
import '../../../domain/trust/models/trust_content.dart';
import '../../../domain/trust/repositories/trust_repository.dart';
import '../../content/remote/app_content_data_source.dart';

/// Reads the trust content from the content data source and maps it.
class TrustRepositoryImpl implements TrustRepository {
  /// Creates the repository.
  const TrustRepositoryImpl(this._content);

  final AppContentDataSource _content;

  @override
  Future<TrustContent> getTrust() async =>
      mapTrust(await _content.fetchSection(ContentSections.trust));
}
