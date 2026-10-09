import '../models/reviews_content.dart';

/// Where the reviews come from.
abstract interface class ReviewsRepository {
  /// The ratings summary and the featured reviews.
  Future<ReviewsContent> getReviews();
}
