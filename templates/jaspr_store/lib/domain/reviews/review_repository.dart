library;

import 'models/review.dart';

abstract interface class ReviewRepository {
  /// Newest first.
  Future<List<Review>> forProduct(String productId);
  Future<Map<String, RatingSummary>> summaries();
}

class GetReviews {
  const GetReviews(this._reviews);
  final ReviewRepository _reviews;

  Future<List<Review>> call(String productId, {int limit = 20}) async {
    final all = await _reviews.forProduct(productId);
    final sorted = [...all]..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(limit).toList();
  }
}
