import '../models/kpi.dart';
import '../models/revenue_point.dart';

/// Turns decoded JSON from the overview endpoints into domain models.
abstract final class OverviewMapper {
  /// Maps one KPI.
  static Kpi kpi(Map<String, Object?> json) => Kpi(
    id: json['id']! as String,
    label: json['label']! as String,
    value: (json['value']! as num).toDouble(),
    unit: KpiUnit.values.byName(json['unit']! as String),
    delta: (json['delta']! as num).toDouble(),
    lowerIsBetter: json['lowerIsBetter'] as bool? ?? false,
  );

  /// Maps one revenue point.
  static RevenuePoint revenuePoint(Map<String, Object?> json) => RevenuePoint(
    label: json['label']! as String,
    current: (json['current']! as num).toDouble(),
    previous: (json['previous']! as num).toDouble(),
  );
}
