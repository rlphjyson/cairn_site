import '../models/gallery_content.dart';
import '../repositories/gallery_repository.dart';

/// Loads the gallery content.
class GetGallery {
  /// Creates the use case.
  const GetGallery(this._repository);

  final GalleryRepository _repository;

  /// Runs the use case.
  Future<GalleryContent> call() => _repository.getGallery();
}
