import 'package:equatable/equatable.dart';

/// One customer review.
class Review extends Equatable {
  /// Creates a review.
  const Review({
    required this.author,
    required this.rating,
    required this.text,
    required this.date,
  });

  /// Who wrote it.
  final String author;

  /// Stars out of five.
  final double rating;

  /// The review text.
  final String text;

  /// When it was written.
  final DateTime date;

  /// Up to two letters for an avatar.
  String get initials {
    final List<String> parts = author
        .trim()
        .split(RegExp(r'\s+'))
        .where((String p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  List<Object?> get props => <Object?>[author, rating, text, date];
}
