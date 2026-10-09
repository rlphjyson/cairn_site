import '../models/gallery_content.dart';

/// Where the gallery content comes from.
abstract interface class GalleryRepository {
  /// The section content.
  Future<GalleryContent> getGallery();
}
