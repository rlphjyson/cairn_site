import '../models/conversion_rate.dart';
import '../models/device_usage.dart';
import '../models/traffic_source.dart';
import '../models/visits_point.dart';

/// Turns decoded JSON from the analytics endpoints into domain models.
abstract final class AnalyticsMapper {
  /// Maps one traffic source.
  static TrafficSource trafficSource(Map<String, Object?> json) =>
      TrafficSource(
        label: json['label']! as String,
        share: (json['share']! as num).toDouble(),
      );

  /// Maps one device row.
  static DeviceUsage device(Map<String, Object?> json) => DeviceUsage(
    label: json['label']! as String,
    sessions: (json['sessions']! as num).toInt(),
  );

  /// Maps one visits point.
  static VisitsPoint visits(Map<String, Object?> json) => VisitsPoint(
    label: json['label']! as String,
    visitors: (json['visitors']! as num).toDouble(),
    returning: (json['returning']! as num).toDouble(),
  );

  /// Maps the conversion figure.
  static ConversionRate conversion(Map<String, Object?> json) => ConversionRate(
    rate: (json['rate']! as num).toDouble(),
    target: (json['target']! as num).toDouble(),
  );
}
