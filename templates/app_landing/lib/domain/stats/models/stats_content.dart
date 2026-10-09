import 'package:equatable/equatable.dart';

/// The numbers band.
class StatsContent extends Equatable {
  /// Creates the content.
  const StatsContent({
    required this.title,
    required this.caption,
    required this.photo,
    required this.photoLabel,
    required this.stats,
  });

  /// The heading above the numbers.
  final String title;

  /// The line over the photo.
  final String caption;

  /// The photo asset beside the numbers.
  final String photo;

  /// What the photo shows, for screen readers.
  final String photoLabel;

  /// The numbers.
  final List<StatItem> stats;

  @override
  List<Object?> get props => <Object?>[
    title,
    caption,
    photo,
    photoLabel,
    stats,
  ];
}

/// One number.
class StatItem extends Equatable {
  /// Creates a stat.
  const StatItem({
    required this.label,
    required this.value,
    required this.description,
  });

  /// What is counted.
  final String label;

  /// The figure, already formatted (such as `12k+`).
  final String value;

  /// A line of context.
  final String description;

  @override
  List<Object?> get props => <Object?>[label, value, description];
}
