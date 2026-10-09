import '../../../domain/filters/models/period.dart';
import '../../../domain/overview/mappers/overview_mapper.dart';
import '../../../domain/overview/models/kpi.dart';
import '../../../domain/overview/models/revenue_point.dart';
import '../../../domain/overview/repositories/overview_repository.dart';
import '../remote/overview_remote_data_source.dart';

/// [OverviewRepository] backed by an [OverviewRemoteDataSource].
class OverviewRepositoryImpl implements OverviewRepository {
  /// Creates the repository.
  OverviewRepositoryImpl(this._dataSource);

  final OverviewRemoteDataSource _dataSource;

  @override
  Future<List<Kpi>> getKpis(Period period) async =>
      (await _dataSource.fetchKpis(
        period.name,
      )).map(OverviewMapper.kpi).toList();

  @override
  Future<List<RevenuePoint>> getRevenue(Period period) async =>
      (await _dataSource.fetchRevenue(
        period.name,
      )).map(OverviewMapper.revenuePoint).toList();
}
