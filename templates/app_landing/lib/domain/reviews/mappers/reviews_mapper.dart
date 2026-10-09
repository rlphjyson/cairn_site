import '../../../common/utils/json.dart';
import '../models/reviews_content.dart';

/// Maps the reviews JSON.
///
/// `distribution` is `{"5": 103200, "4": 10800, ...}`; dates are ISO 8601
/// (`2026-09-14`).
ReviewsContent mapReviews(JsonMap json) => ReviewsContent(
  eyebrow: json.string('eyebrow'),
  title: json.string('title'),
  subtitle: json.string('subtitle'),
  distribution: _distribution(json.object('distribution')),
  reviews: <Review>[
    for (final JsonMap e in json.objects('reviews'))
      Review(
        id: e.string('id'),
        title: e.string('title'),
        body: e.string('body'),
        author: e.string('author'),
        date: DateTime.parse(e.string('date')),
        rating: e.number('rating').round().clamp(1, 5),
        avatar: e.maybeString('avatar'),
      ),
  ],
  writeReview: _prompt(json.object('writeReview')),
);

RatingDistribution _distribution(JsonMap j) => RatingDistribution(<int, int>{
  for (final int star in RatingDistribution.stars)
    star: j.number('$star').round(),
});

WriteReviewPrompt _prompt(JsonMap j) => WriteReviewPrompt(
  label: j.string('label'),
  toastTitle: j.string('toastTitle'),
  toastMessage: j.string('toastMessage'),
);
