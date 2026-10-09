import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/filters/models/period.dart';
import '../../../domain/orders/models/order.dart';
import '../../../domain/orders/use_cases/get_recent_orders.dart';
import '../../../domain/overview/models/kpi.dart';
import '../../../domain/overview/models/revenue_point.dart';
import '../../../domain/overview/use_cases/get_kpis.dart';
import '../../../domain/overview/use_cases/get_revenue_series.dart';

/// What the overview page is showing.
class OverviewState extends Equatable {
  /// Creates a state.
  const OverviewState({
    this.loading = true,
    this.kpis = const <Kpi>[],
    this.revenue = const <RevenuePoint>[],
    this.recent = const <Order>[],
    this.failed = false,
  });

  /// Whether the first load is still running.
  final bool loading;

  /// Headline figures.
  final List<Kpi> kpis;

  /// The revenue chart's points.
  final List<RevenuePoint> revenue;

  /// The newest orders.
  final List<Order> recent;

  /// Whether the last load failed.
  final bool failed;

  @override
  List<Object?> get props => <Object?>[loading, kpis, revenue, recent, failed];
}

/// State for the overview page. Scoped to one visit; its view model closes it.
class OverviewCubit extends Cubit<OverviewState> {
  /// Creates the cubit.
  OverviewCubit(this._getKpis, this._getRevenue, this._getRecent)
    : super(const OverviewState());

  final GetKpis _getKpis;
  final GetRevenueSeries _getRevenue;
  final GetRecentOrders _getRecent;

  /// Loads everything for [period]. Keeps the old figures on screen until the
  /// new ones arrive, so changing period never flashes empty.
  Future<void> load(Period period) async {
    try {
      final List<Object> results = await Future.wait<Object>(<Future<Object>>[
        _getKpis(period),
        _getRevenue(period),
        _getRecent(),
      ]);
      if (isClosed) return;
      emit(
        OverviewState(
          loading: false,
          kpis: results[0] as List<Kpi>,
          revenue: results[1] as List<RevenuePoint>,
          recent: results[2] as List<Order>,
        ),
      );
    } on Object {
      if (isClosed) return;
      emit(
        OverviewState(
          loading: false,
          kpis: state.kpis,
          revenue: state.revenue,
          recent: state.recent,
          failed: true,
        ),
      );
    }
  }
}
