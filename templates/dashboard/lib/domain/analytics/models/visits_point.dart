import 'package:equatable/equatable.dart';

/// New and returning visitors for one step of the chart.
class VisitsPoint extends Equatable {
  /// Creates a point.
  const VisitsPoint({
    required this.label,
    required this.visitors,
    required this.returning,
  });

  /// The x-axis label.
  final String label;

  /// All visitors.
  final double visitors;

  /// Of those, how many had been before.
  final double returning;

  @override
  List<Object?> get props => <Object?>[label, visitors, returning];
}
