import 'package:flutter_bloc/flutter_bloc.dart';

/// The pages in the sidebar, in order.
enum DashboardPage {
  /// KPIs, revenue and recent orders.
  overview('Overview'),

  /// Traffic, devices, visitors and conversion.
  analytics('Analytics'),

  /// The full orders table.
  orders('Orders');

  const DashboardPage(this.label);

  /// The sidebar label and page title.
  final String label;
}

/// Which page is showing.
///
/// The template keeps its own navigation so it runs inside any host app. In a
/// real project, swap this cubit for `go_router` and keep every view.
class DashboardNavigationCubit extends Cubit<DashboardPage> {
  /// Creates the cubit.
  DashboardNavigationCubit() : super(DashboardPage.overview);

  /// Shows [page].
  void select(DashboardPage page) => emit(page);
}
