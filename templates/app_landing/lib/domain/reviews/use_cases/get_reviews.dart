import '../models/reviews_content.dart';
import '../repositories/reviews_repository.dart';

/// Loads the reviews and puts the newest first.
class GetReviews {
  /// Creates the use case.
  const GetReviews(this._repository);

  final ReviewsRepository _repository;

  /// Runs the use case.
  Future<ReviewsContent> call() async {
    final ReviewsContent content = await _repository.getReviews();
    final List<Review> sorted = <Review>[...content.reviews]
      ..sort((Review a, Review b) => b.date.compareTo(a.date));
    return ReviewsContent(
      eyebrow: content.eyebrow,
      title: content.title,
      subtitle: content.subtitle,
      distribution: content.distribution,
      reviews: sorted,
      writeReview: content.writeReview,
    );
  }
}
