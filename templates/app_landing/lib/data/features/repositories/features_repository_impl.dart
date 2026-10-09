import '../../../common/constants/content_sections.dart';
import '../../../domain/features/mappers/features_mapper.dart';
import '../../../domain/features/models/features_content.dart';
import '../../../domain/features/repositories/features_repository.dart';
import '../../content/remote/app_content_data_source.dart';

/// Reads the features content from the content data source and maps it.
class FeaturesRepositoryImpl implements FeaturesRepository {
  /// Creates the repository.
  const FeaturesRepositoryImpl(this._content);

  final AppContentDataSource _content;

  @override
  Future<FeaturesContent> getFeatures() async =>
      mapFeatures(await _content.fetchSection(ContentSections.features));
}
