import '../../filters/models/period.dart';
import '../models/traffic_source.dart';
import '../repositories/analytics_repository.dart';

/// Loads one analytics figure for a period.
class GetTrafficSources {
  /// Creates the use case.
  const GetTrafficSources(this._repository);

  final AnalyticsRepository _repository;

  /// Runs it.
  Future<List<TrafficSource>> call(Period period) =>
      _repository.getTrafficSources(period);
}
