import '../../filters/models/period.dart';
import '../models/kpi.dart';
import '../models/revenue_point.dart';

/// Where the overview figures come from.
abstract interface class OverviewRepository {
  /// The headline figures for [period].
  Future<List<Kpi>> getKpis(Period period);

  /// Revenue over [period], with the previous period alongside.
  Future<List<RevenuePoint>> getRevenue(Period period);
}
