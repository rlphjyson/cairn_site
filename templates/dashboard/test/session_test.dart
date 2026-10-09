import 'package:cairn_template_dashboard/core/infrastructure/di/dashboard_injection.dart';
import 'package:cairn_template_dashboard/core/presentation/navigation/dashboard_navigation_cubit.dart';
import 'package:cairn_template_dashboard/data/orders/remote/orders_remote_data_source.dart';
import 'package:cairn_template_dashboard/domain/filters/models/period.dart';
import 'package:cairn_template_dashboard/domain/orders/models/order.dart';
import 'package:cairn_template_dashboard/presentation/analytics/view_models/analytics_view_model.dart';
import 'package:cairn_template_dashboard/presentation/filters/bloc/period_cubit.dart';
import 'package:cairn_template_dashboard/presentation/orders/view_models/orders_view_model.dart';
import 'package:cairn_template_dashboard/presentation/overview/view_models/overview_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

/// Cubits wired through the real container, with no widgets.
void main() {
  late GetIt locator;

  setUp(() => locator = createDashboardLocator());
  tearDown(() => locator.reset());

  test('session cubits are singletons, view models are not', () {
    expect(identical(locator<PeriodCubit>(), locator<PeriodCubit>()), isTrue);
    expect(
      identical(
        locator<DashboardNavigationCubit>(),
        locator<DashboardNavigationCubit>(),
      ),
      isTrue,
    );
    expect(
      identical(locator<OverviewViewModel>(), locator<OverviewViewModel>()),
      isFalse,
    );
  });

  test('containers are independent', () {
    final GetIt other = createDashboardLocator();
    expect(identical(locator<PeriodCubit>(), other<PeriodCubit>()), isFalse);
    other.reset();
  });

  test('the period defaults to a week and can change', () {
    final PeriodCubit period = locator<PeriodCubit>();
    expect(period.state, Period.week);
    period.select(Period.year);
    expect(period.state, Period.year);
  });

  test('navigation selects a page', () {
    final DashboardNavigationCubit nav = locator<DashboardNavigationCubit>();
    expect(nav.state, DashboardPage.overview);
    nav.select(DashboardPage.orders);
    expect(nav.state, DashboardPage.orders);
  });

  test('the overview cubit loads figures for a period', () async {
    final OverviewViewModel vm = locator<OverviewViewModel>();
    expect(vm.cubit.state.loading, isTrue);
    await vm.cubit.load(Period.month);
    expect(vm.cubit.state.loading, isFalse);
    expect(vm.cubit.state.kpis, hasLength(4));
    expect(vm.cubit.state.revenue, hasLength(6));
    expect(vm.cubit.state.recent, hasLength(5));
    vm.dispose();
    expect(vm.cubit.isClosed, isTrue);
  });

  test('the analytics cubit loads every chart', () async {
    final AnalyticsViewModel vm = locator<AnalyticsViewModel>();
    await vm.cubit.load(Period.year);
    expect(vm.cubit.state.traffic, isNotEmpty);
    expect(vm.cubit.state.devices, hasLength(3));
    expect(vm.cubit.state.visits, hasLength(12));
    expect(vm.cubit.state.conversion, isNotNull);
    vm.dispose();
  });

  test('the orders cubit filters by status', () async {
    final OrdersViewModel vm = locator<OrdersViewModel>();
    await vm.cubit.load();
    final int all = vm.cubit.state.visible.length;
    vm.cubit.selectStatus(OrderStatus.failed);
    expect(vm.cubit.state.visible.length, lessThan(all));
    expect(
      vm.cubit.state.visible.every((Order o) => o.status == OrderStatus.failed),
      isTrue,
    );
    vm.cubit.selectStatus(null);
    expect(vm.cubit.state.visible.length, all);
    vm.dispose();
  });

  test(
    'a failing data source surfaces as a failed state, then recovers',
    () async {
      locator
        ..unregister<OrdersRemoteDataSource>()
        ..registerLazySingleton<OrdersRemoteDataSource>(_FlakyOrders.new);
      final OrdersViewModel vm = locator<OrdersViewModel>();

      await vm.cubit.load();
      expect(vm.cubit.state.failed, isTrue);
      expect(vm.cubit.state.orders, isEmpty);

      await vm.cubit.load();
      expect(vm.cubit.state.failed, isFalse);
      expect(vm.cubit.state.orders, isNotEmpty);
      vm.dispose();
    },
  );
}

/// Throws on the first call, then behaves.
class _FlakyOrders implements OrdersRemoteDataSource {
  int _calls = 0;

  @override
  Future<List<Map<String, Object?>>> fetchOrders() async {
    if (_calls++ == 0) throw Exception('offline');
    return const InMemoryOrdersRemoteDataSource().fetchOrders();
  }
}
