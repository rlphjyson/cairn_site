import 'package:equatable/equatable.dart';

/// The numbers band.
class StatsContent extends Equatable {
  /// Creates the content.
  const StatsContent({required this.title, required this.stats});

  /// The heading above the numbers.
  final String title;

  /// The numbers.
  final List<StatItem> stats;

  @override
  List<Object?> get props => <Object?>[title, stats];
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
