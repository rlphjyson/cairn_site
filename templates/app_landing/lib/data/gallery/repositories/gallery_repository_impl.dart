import '../../../common/constants/content_sections.dart';
import '../../../domain/gallery/mappers/gallery_mapper.dart';
import '../../../domain/gallery/models/gallery_content.dart';
import '../../../domain/gallery/repositories/gallery_repository.dart';
import '../../content/remote/app_content_data_source.dart';

/// Reads the gallery content from the content data source and maps it.
class GalleryRepositoryImpl implements GalleryRepository {
  /// Creates the repository.
  const GalleryRepositoryImpl(this._content);

  final AppContentDataSource _content;

  @override
  Future<GalleryContent> getGallery() async =>
      mapGallery(await _content.fetchSection(ContentSections.gallery));
}
