import 'package:cairn_template_dashboard/common/utils/chart_scale.dart';
import 'package:cairn_template_dashboard/common/utils/format.dart';
import 'package:cairn_template_dashboard/data/orders/remote/orders_remote_data_source.dart';
import 'package:cairn_template_dashboard/data/orders/repositories/orders_repository_impl.dart';
import 'package:cairn_template_dashboard/data/overview/remote/overview_remote_data_source.dart';
import 'package:cairn_template_dashboard/data/overview/repositories/overview_repository_impl.dart';
import 'package:cairn_template_dashboard/domain/analytics/models/conversion_rate.dart';
import 'package:cairn_template_dashboard/domain/filters/models/period.dart';
import 'package:cairn_template_dashboard/domain/orders/models/order.dart';
import 'package:cairn_template_dashboard/domain/orders/use_cases/filter_orders.dart';
import 'package:cairn_template_dashboard/domain/orders/use_cases/get_recent_orders.dart';
import 'package:cairn_template_dashboard/domain/overview/models/kpi.dart';
import 'package:cairn_template_dashboard/domain/overview/models/revenue_point.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DashboardFormat', () {
    test('groups thousands', () {
      expect(DashboardFormat.number(31200), '31,200');
      expect(DashboardFormat.number(999), '999');
      expect(DashboardFormat.number(1234567), '1,234,567');
      expect(DashboardFormat.currency(250), '\$250');
    });

    test('compacts axis values', () {
      expect(DashboardFormat.compact(950), '950');
      expect(DashboardFormat.compact(2500), '2.5k');
      expect(DashboardFormat.compact(10000), '10k');
      expect(DashboardFormat.compact(1500000), '1.5M');
    });

    test('signs percentages', () {
      expect(DashboardFormat.signedPercent(12.5), '+12.5%');
      expect(DashboardFormat.signedPercent(-4.6), '-4.6%');
      expect(DashboardFormat.percent(3.24), '3.2%');
    });
  });

  group('niceCeil', () {
    test('rounds up to a readable axis maximum', () {
      expect(niceCeil(0), 1);
      expect(niceCeil(4300), 5000);
      expect(niceCeil(5100), 10000);
      expect(niceCeil(1700), 2000);
      expect(niceCeil(2200), 2500);
    });
  });

  group('overview', () {
    final OverviewRepositoryImpl repository = OverviewRepositoryImpl(
      const InMemoryOverviewRemoteDataSource(),
    );

    test('every period has the right number of points', () async {
      expect((await repository.getRevenue(Period.week)).length, 7);
      expect((await repository.getRevenue(Period.month)).length, 6);
      expect((await repository.getRevenue(Period.year)).length, 12);
    });

    test('the revenue KPI is the sum of the series', () async {
      for (final Period p in Period.values) {
        final List<RevenuePoint> series = await repository.getRevenue(p);
        final List<Kpi> kpis = await repository.getKpis(p);
        final Kpi revenue = kpis.firstWhere((Kpi k) => k.id == 'revenue');
        expect(
          revenue.value,
          series.fold<double>(0, (double s, RevenuePoint r) => s + r.current),
        );
      }
    });

    test('a falling refund rate counts as an improvement', () async {
      final List<Kpi> kpis = await repository.getKpis(Period.week);
      final Kpi refunds = kpis.firstWhere((Kpi k) => k.id == 'refund-rate');
      expect(refunds.delta, lessThan(0));
      expect(refunds.improving, isTrue);
      expect(kpis.firstWhere((Kpi k) => k.id == 'sales').improving, isTrue);
    });
  });

  group('orders', () {
    final OrdersRepositoryImpl repository = OrdersRepositoryImpl(
      const InMemoryOrdersRemoteDataSource(),
    );

    test('are newest first and unique', () async {
      final List<Order> orders = await repository.getOrders();
      expect(orders.length, 24);
      expect(orders.map((Order o) => o.id).toSet().length, orders.length);
      for (int i = 1; i < orders.length; i++) {
        expect(orders[i].date.isAfter(orders[i - 1].date), isFalse);
      }
    });

    test('recent returns the newest few', () async {
      final List<Order> recent = await GetRecentOrders(repository)(limit: 3);
      expect(recent.map((Order o) => o.id), <String>[
        '#3248',
        '#3247',
        '#3246',
      ]);
    });

    test('filtering by status keeps only that status', () async {
      final List<Order> all = await repository.getOrders();
      const FilterOrders filter = FilterOrders();
      expect(filter(all), all);
      for (final OrderStatus s in OrderStatus.values) {
        final List<Order> some = filter(all, status: s);
        expect(some.every((Order o) => o.status == s), isTrue);
      }
    });
  });

  test('conversion progress is clamped to the target', () {
    expect(const ConversionRate(rate: 2.25, target: 4.5).progress, 0.5);
    expect(const ConversionRate(rate: 9, target: 4.5).progress, 1);
  });
}
