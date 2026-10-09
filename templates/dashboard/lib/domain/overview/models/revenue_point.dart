import 'package:equatable/equatable.dart';

/// Revenue for one step of the chart, with the previous period beside it.
class RevenuePoint extends Equatable {
  /// Creates a point.
  const RevenuePoint({
    required this.label,
    required this.current,
    required this.previous,
  });

  /// The x-axis label.
  final String label;

  /// Revenue in this period.
  final double current;

  /// Revenue in the period before.
  final double previous;

  @override
  List<Object?> get props => <Object?>[label, current, previous];
}
