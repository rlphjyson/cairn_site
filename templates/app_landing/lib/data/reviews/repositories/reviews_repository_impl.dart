import '../../../common/constants/content_sections.dart';
import '../../../domain/reviews/mappers/reviews_mapper.dart';
import '../../../domain/reviews/models/reviews_content.dart';
import '../../../domain/reviews/repositories/reviews_repository.dart';
import '../../content/remote/app_content_data_source.dart';

/// Reads the reviews content from the content data source and maps it.
class ReviewsRepositoryImpl implements ReviewsRepository {
  /// Creates the repository.
  const ReviewsRepositoryImpl(this._content);

  final AppContentDataSource _content;

  @override
  Future<ReviewsContent> getReviews() async =>
      mapReviews(await _content.fetchSection(ContentSections.reviews));
}
