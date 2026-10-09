import '../../filters/models/period.dart';
import '../models/kpi.dart';
import '../repositories/overview_repository.dart';

/// Loads the headline figures.
class GetKpis {
  /// Creates the use case.
  const GetKpis(this._repository);

  final OverviewRepository _repository;

  /// Runs it.
  Future<List<Kpi>> call(Period period) => _repository.getKpis(period);
}
