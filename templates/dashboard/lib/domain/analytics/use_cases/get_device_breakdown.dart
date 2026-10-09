import '../../filters/models/period.dart';
import '../models/device_usage.dart';
import '../repositories/analytics_repository.dart';

/// Loads one analytics figure for a period.
class GetDeviceBreakdown {
  /// Creates the use case.
  const GetDeviceBreakdown(this._repository);

  final AnalyticsRepository _repository;

  /// Runs it.
  Future<List<DeviceUsage>> call(Period period) =>
      _repository.getDevices(period);
}
