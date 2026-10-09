import '../../filters/models/period.dart';
import '../models/conversion_rate.dart';
import '../models/device_usage.dart';
import '../models/traffic_source.dart';
import '../models/visits_point.dart';

/// Where the analytics figures come from.
abstract interface class AnalyticsRepository {
  /// Share of sessions by channel.
  Future<List<TrafficSource>> getTrafficSources(Period period);

  /// Sessions by device.
  Future<List<DeviceUsage>> getDevices(Period period);

  /// Visitors over time.
  Future<List<VisitsPoint>> getVisits(Period period);

  /// The conversion rate against target.
  Future<ConversionRate> getConversion(Period period);
}
