library;

import '../../backend/stores.dart';
import '../../domain/reviews/models/review.dart';
import '../../domain/reviews/review_repository.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  ReviewRepositoryImpl(this._store);
  final ReviewStore _store;

  @override
  Future<List<Review>> forProduct(String productId) async =>
      _store.reviews.where((r) => r.productId == productId).toList();

  @override
  Future<Map<String, RatingSummary>> summaries() async {
    final byProduct = <String, List<Review>>{};
    for (final r in _store.reviews) {
      byProduct.putIfAbsent(r.productId, () => []).add(r);
    }
    return {for (final e in byProduct.entries) e.key: RatingSummary.from(e.value)};
  }
}
