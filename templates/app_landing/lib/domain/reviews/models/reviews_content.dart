import 'package:equatable/equatable.dart';

/// The ratings and reviews section.
class ReviewsContent extends Equatable {
  /// Creates the content.
  const ReviewsContent({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.distribution,
    required this.reviews,
    required this.writeReview,
  });

  /// The label above the title.
  final String eyebrow;

  /// The section title.
  final String title;

  /// The copy under the title.
  final String subtitle;

  /// How many people gave each star count.
  final RatingDistribution distribution;

  /// The featured reviews, newest first.
  final List<Review> reviews;

  /// The call to action under the reviews.
  final WriteReviewPrompt writeReview;

  @override
  List<Object?> get props => <Object?>[
    eyebrow,
    title,
    subtitle,
    distribution,
    reviews,
    writeReview,
  ];
}

/// How many people gave one, two, three, four and five stars.
///
/// Everything else on the summary (the total, the average, the share of each
/// bar) is derived from these five counts, so they cannot disagree.
class RatingDistribution extends Equatable {
  /// Creates a distribution from a count per star (1 to 5).
  const RatingDistribution(this.counts);

  /// The star counts, keyed 1 to 5.
  final Map<int, int> counts;

  /// The star levels, highest first.
  static const List<int> stars = <int>[5, 4, 3, 2, 1];

  /// How many people gave [star] stars.
  int countFor(int star) => counts[star] ?? 0;

  /// How many ratings there are in all.
  int get total => stars.fold(0, (int sum, int s) => sum + countFor(s));

  /// The mean rating, from 0 to 5; zero when there are no ratings.
  double get average {
    if (total == 0) return 0;
    final int points = stars.fold(0, (int sum, int s) => sum + s * countFor(s));
    return points / total;
  }

  /// The average rounded to one decimal, as shown to people: `4.8`.
  String get averageLabel => average.toStringAsFixed(1);

  /// The share of all ratings that gave [star] stars, from 0 to 1.
  double shareFor(int star) => total == 0 ? 0 : countFor(star) / total;

  @override
  List<Object?> get props => <Object?>[for (final int s in stars) countFor(s)];
}

/// One review.
class Review extends Equatable {
  /// Creates a review.
  const Review({
    required this.id,
    required this.title,
    required this.body,
    required this.author,
    required this.date,
    required this.rating,
    required this.avatar,
  });

  /// A stable id.
  final String id;

  /// The review headline.
  final String title;

  /// The review text.
  final String body;

  /// The reviewer's display name.
  final String author;

  /// When it was written.
  final DateTime date;

  /// Stars, 1 to 5.
  final int rating;

  /// An avatar asset, or `null` for initials.
  final String? avatar;

  @override
  List<Object?> get props => <Object?>[
    id,
    title,
    body,
    author,
    date,
    rating,
    avatar,
  ];
}

/// The "Write a review" call to action and what it says when pressed.
class WriteReviewPrompt extends Equatable {
  /// Creates the prompt.
  const WriteReviewPrompt({
    required this.label,
    required this.toastTitle,
    required this.toastMessage,
  });

  /// The button label.
  final String label;

  /// The toast title.
  final String toastTitle;

  /// The toast message.
  final String toastMessage;

  @override
  List<Object?> get props => <Object?>[label, toastTitle, toastMessage];
}
