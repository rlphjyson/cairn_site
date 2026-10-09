import '../../../domain/analytics/mappers/analytics_mapper.dart';
import '../../../domain/analytics/models/conversion_rate.dart';
import '../../../domain/analytics/models/device_usage.dart';
import '../../../domain/analytics/models/traffic_source.dart';
import '../../../domain/analytics/models/visits_point.dart';
import '../../../domain/analytics/repositories/analytics_repository.dart';
import '../../../domain/filters/models/period.dart';
import '../remote/analytics_remote_data_source.dart';

/// [AnalyticsRepository] backed by an [AnalyticsRemoteDataSource].
class AnalyticsRepositoryImpl implements AnalyticsRepository {
  /// Creates the repository.
  AnalyticsRepositoryImpl(this._dataSource);

  final AnalyticsRemoteDataSource _dataSource;

  @override
  Future<List<TrafficSource>> getTrafficSources(Period period) async =>
      (await _dataSource.fetchTraffic(
        period.name,
      )).map(AnalyticsMapper.trafficSource).toList();

  @override
  Future<List<DeviceUsage>> getDevices(Period period) async =>
      (await _dataSource.fetchDevices(
        period.name,
      )).map(AnalyticsMapper.device).toList();

  @override
  Future<List<VisitsPoint>> getVisits(Period period) async =>
      (await _dataSource.fetchVisits(
        period.name,
      )).map(AnalyticsMapper.visits).toList();

  @override
  Future<ConversionRate> getConversion(Period period) async =>
      AnalyticsMapper.conversion(
        await _dataSource.fetchConversion(period.name),
      );
}
