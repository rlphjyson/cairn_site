import '../../filters/models/period.dart';
import '../models/revenue_point.dart';
import '../repositories/overview_repository.dart';

/// Loads the revenue chart's data.
class GetRevenueSeries {
  /// Creates the use case.
  const GetRevenueSeries(this._repository);

  final OverviewRepository _repository;

  /// Runs it.
  Future<List<RevenuePoint>> call(Period period) =>
      _repository.getRevenue(period);
}
