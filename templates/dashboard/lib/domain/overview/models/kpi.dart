import 'package:equatable/equatable.dart';

/// How a [Kpi] value is written.
enum KpiUnit {
  /// Dollars.
  currency,

  /// A plain count.
  count,

  /// A percentage.
  percent,
}

/// One headline figure.
class Kpi extends Equatable {
  /// Creates a KPI.
  const Kpi({
    required this.id,
    required this.label,
    required this.value,
    required this.unit,
    required this.delta,
    this.lowerIsBetter = false,
  });

  /// Stable key.
  final String id;

  /// What it measures.
  final String label;

  /// The figure.
  final double value;

  /// How [value] is written.
  final KpiUnit unit;

  /// Change against the previous period, in percent.
  final double delta;

  /// Whether a falling figure is good news (refund rate, say).
  final bool lowerIsBetter;

  /// Whether the change is an improvement.
  bool get improving => lowerIsBetter ? delta <= 0 : delta >= 0;

  @override
  List<Object?> get props => <Object?>[
    id,
    label,
    value,
    unit,
    delta,
    lowerIsBetter,
  ];
}
