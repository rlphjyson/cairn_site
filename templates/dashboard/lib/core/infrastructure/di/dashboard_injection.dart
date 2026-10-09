import 'package:get_it/get_it.dart';

import '../../../data/analytics/remote/analytics_remote_data_source.dart';
import '../../../data/analytics/repositories/analytics_repository_impl.dart';
import '../../../data/orders/remote/orders_remote_data_source.dart';
import '../../../data/orders/repositories/orders_repository_impl.dart';
import '../../../data/overview/remote/overview_remote_data_source.dart';
import '../../../data/overview/repositories/overview_repository_impl.dart';
import '../../../domain/analytics/repositories/analytics_repository.dart';
import '../../../domain/analytics/use_cases/get_conversion_rate.dart';
import '../../../domain/analytics/use_cases/get_device_breakdown.dart';
import '../../../domain/analytics/use_cases/get_traffic_sources.dart';
import '../../../domain/analytics/use_cases/get_visits_series.dart';
import '../../../domain/orders/repositories/orders_repository.dart';
import '../../../domain/orders/use_cases/filter_orders.dart';
import '../../../domain/orders/use_cases/get_orders.dart';
import '../../../domain/orders/use_cases/get_recent_orders.dart';
import '../../../domain/overview/repositories/overview_repository.dart';
import '../../../domain/overview/use_cases/get_kpis.dart';
import '../../../domain/overview/use_cases/get_revenue_series.dart';
import '../../../presentation/analytics/bloc/analytics_cubit.dart';
import '../../../presentation/analytics/view_models/analytics_view_model.dart';
import '../../../presentation/filters/bloc/period_cubit.dart';
import '../../../presentation/orders/bloc/orders_cubit.dart';
import '../../../presentation/orders/view_models/orders_view_model.dart';
import '../../../presentation/overview/bloc/overview_cubit.dart';
import '../../../presentation/overview/view_models/overview_view_model.dart';
import '../../presentation/navigation/dashboard_navigation_cubit.dart';

/// Builds a fresh dependency container for one mount of the template.
///
/// Registration is explicit, so there is no `build_runner` step. Scopes:
///
/// * data sources and repositories: lazy singletons;
/// * use cases: factories (stateless and free to build);
/// * **session cubits** (navigation, period): lazy singletons, provided once
///   and never closed by a view model;
/// * **screen cubits** (overview, analytics, orders): created and closed by
///   their view model.
GetIt createDashboardLocator() {
  final GetIt g = GetIt.asNewInstance();

  g
    ..registerLazySingleton<OverviewRemoteDataSource>(
      InMemoryOverviewRemoteDataSource.new,
    )
    ..registerLazySingleton<AnalyticsRemoteDataSource>(
      InMemoryAnalyticsRemoteDataSource.new,
    )
    ..registerLazySingleton<OrdersRemoteDataSource>(
      InMemoryOrdersRemoteDataSource.new,
    );

  g
    ..registerLazySingleton<OverviewRepository>(
      () => OverviewRepositoryImpl(g()),
    )
    ..registerLazySingleton<AnalyticsRepository>(
      () => AnalyticsRepositoryImpl(g()),
    )
    ..registerLazySingleton<OrdersRepository>(() => OrdersRepositoryImpl(g()));

  g
    ..registerFactory<GetKpis>(() => GetKpis(g()))
    ..registerFactory<GetRevenueSeries>(() => GetRevenueSeries(g()))
    ..registerFactory<GetTrafficSources>(() => GetTrafficSources(g()))
    ..registerFactory<GetDeviceBreakdown>(() => GetDeviceBreakdown(g()))
    ..registerFactory<GetVisitsSeries>(() => GetVisitsSeries(g()))
    ..registerFactory<GetConversionRate>(() => GetConversionRate(g()))
    ..registerFactory<GetOrders>(() => GetOrders(g()))
    ..registerFactory<GetRecentOrders>(() => GetRecentOrders(g()))
    ..registerFactory<FilterOrders>(FilterOrders.new);

  g
    ..registerLazySingleton<DashboardNavigationCubit>(
      DashboardNavigationCubit.new,
      dispose: (DashboardNavigationCubit c) => c.close(),
    )
    ..registerLazySingleton<PeriodCubit>(
      PeriodCubit.new,
      dispose: (PeriodCubit c) => c.close(),
    );

  g
    ..registerFactory<OverviewViewModel>(
      () => OverviewViewModel(OverviewCubit(g(), g(), g())),
    )
    ..registerFactory<AnalyticsViewModel>(
      () => AnalyticsViewModel(AnalyticsCubit(g(), g(), g(), g())),
    )
    ..registerFactory<OrdersViewModel>(
      () => OrdersViewModel(OrdersCubit(g(), g())),
    );

  return g;
}
