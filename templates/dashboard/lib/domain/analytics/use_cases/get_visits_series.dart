import '../../filters/models/period.dart';
import '../models/visits_point.dart';
import '../repositories/analytics_repository.dart';

/// Loads one analytics figure for a period.
class GetVisitsSeries {
  /// Creates the use case.
  const GetVisitsSeries(this._repository);

  final AnalyticsRepository _repository;

  /// Runs it.
  Future<List<VisitsPoint>> call(Period period) =>
      _repository.getVisits(period);
}
