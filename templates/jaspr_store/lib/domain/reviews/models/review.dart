library;

import 'package:meta/meta.dart';

@immutable
class Review {
  const Review({
    required this.id,
    required this.productId,
    required this.author,
    required this.rating,
    required this.title,
    required this.body,
    required this.date,
    this.verified = true,
  }) : assert(rating >= 1 && rating <= 5);

  final String id;
  final String productId;
  final String author;

  /// 1 to 5.
  final int rating;
  final String title;
  final String body;
  final DateTime date;
  final bool verified;
}

@immutable
class RatingSummary {
  const RatingSummary({required this.average, required this.count, this.distribution = const {}});

  static const RatingSummary empty = RatingSummary(average: 0, count: 0);

  /// Rounded to one decimal.
  final double average;
  final int count;

  /// Star value (1-5) -> number of reviews.
  final Map<int, int> distribution;

  bool get hasReviews => count > 0;

  factory RatingSummary.from(Iterable<Review> reviews) {
    final list = reviews.toList();
    if (list.isEmpty) return empty;
    final dist = <int, int>{for (var i = 1; i <= 5; i++) i: 0};
    var total = 0;
    for (final r in list) {
      dist[r.rating] = dist[r.rating]! + 1;
      total += r.rating;
    }
    final avg = (total / list.length * 10).round() / 10;
    return RatingSummary(average: avg, count: list.length, distribution: dist);
  }
}
