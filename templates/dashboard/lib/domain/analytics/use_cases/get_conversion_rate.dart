import '../../filters/models/period.dart';
import '../models/conversion_rate.dart';
import '../repositories/analytics_repository.dart';

/// Loads one analytics figure for a period.
class GetConversionRate {
  /// Creates the use case.
  const GetConversionRate(this._repository);

  final AnalyticsRepository _repository;

  /// Runs it.
  Future<ConversionRate> call(Period period) =>
      _repository.getConversion(period);
}
