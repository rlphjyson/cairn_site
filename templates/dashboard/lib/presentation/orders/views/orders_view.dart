import 'package:cairn_ui/cairn_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/utils/format.dart';
import '../../../core/presentation/dashboard_text.dart';
import '../../../core/presentation/view_model.dart';
import '../../../core/presentation/widgets/error_panel.dart';
import '../../../domain/orders/models/order.dart';
import '../bloc/orders_cubit.dart';
import '../view_models/orders_view_model.dart';
import '../widgets/status_badge.dart';

/// Every order, filterable by status and searchable, sortable and paged.
class OrdersView extends StatelessWidget {
  /// Creates the view.
  const OrdersView({super.key});

  @override
  Widget build(BuildContext context) {
    final CairnTheme theme = CairnTheme.of(context);
    return ViewModelBuilder<OrdersViewModel>(
      onCreate: (BuildContext context, OrdersViewModel vm) => vm.cubit.load(),
      builder: (BuildContext context, OrdersViewModel vm) =>
          BlocBuilder<OrdersCubit, OrdersState>(
            bloc: vm.cubit,
            builder: (BuildContext context, OrdersState state) {
              if (state.failed && state.orders.isEmpty) {
                return ErrorPanel(onRetry: vm.cubit.load);
              }
              return ListView(
                padding: const EdgeInsets.all(24),
                children: <Widget>[
                  CairnCard(
                    children: <Widget>[
                      CairnCardHeader(
                        title: const Text('Orders'),
                        description: Text(
                          '${state.visible.length} of ${state.orders.length} '
                          'orders',
                        ),
                      ),
                      CairnCardContent(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                spacing: 8,
                                children: <Widget>[
                                  _Chip(
                                    label: 'All',
                                    selected: state.status == null,
                                    onTap: () => vm.cubit.selectStatus(null),
                                  ),
                                  for (final OrderStatus s
                                      in OrderStatus.values)
                                    _Chip(
                                      label: s.label,
                                      selected: state.status == s,
                                      onTap: () => vm.cubit.selectStatus(s),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (state.loading)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 40),
                                child: Center(child: CairnSpinner()),
                              )
                            else
                              _ScrollableTable(
                                child: CairnDataTable<Order>(
                                  rows: state.visible,
                                  pageSize: 8,
                                  searchBy: (Order o) =>
                                      '${o.id} ${o.customer} ${o.email}',
                                  searchPlaceholder: 'Search orders...',
                                  columns: <CairnColumn<Order>>[
                                    CairnColumn<Order>(
                                      label: 'Order',
                                      flex: 2,
                                      cell: (Order o) => Text(
                                        o.id,
                                        style: dashText(
                                          theme,
                                          theme.textStyle(CairnTypography.sm),
                                          weight: CairnTypography.medium,
                                        ),
                                      ),
                                      sortKey: (Order o) => o.id,
                                    ),
                                    CairnColumn<Order>(
                                      label: 'Customer',
                                      flex: 3,
                                      cell: (Order o) => Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(o.customer),
                                          Text(
                                            o.email,
                                            style: dashText(
                                              theme,
                                              theme.textStyle(
                                                CairnTypography.xs,
                                              ),
                                              color: theme.mutedForeground,
                                            ),
                                          ),
                                        ],
                                      ),
                                      sortKey: (Order o) => o.customer,
                                    ),
                                    CairnColumn<Order>(
                                      label: 'Status',
                                      flex: 2,
                                      cell: (Order o) =>
                                          StatusBadge(status: o.status),
                                      sortKey: (Order o) => o.status.label,
                                    ),
                                    CairnColumn<Order>(
                                      label: 'Date',
                                      flex: 2,
                                      cell: (Order o) => Text(
                                        '${o.date.year}-'
                                        '${o.date.month.toString().padLeft(2, '0')}-'
                                        '${o.date.day.toString().padLeft(2, '0')}',
                                      ),
                                      sortKey: (Order o) => o.date,
                                    ),
                                    CairnColumn<Order>(
                                      label: 'Amount',
                                      flex: 2,
                                      cell: (Order o) => Text(
                                        DashboardFormat.currency(o.amount),
                                      ),
                                      sortKey: (Order o) => o.amount,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => CairnButton(
    size: CairnButtonSize.sm,
    variant: selected ? CairnButtonVariant.primary : CairnButtonVariant.outline,
    onPressed: onTap,
    child: Text(label),
  );
}

/// Lets the table keep a readable width in a narrow frame by scrolling
/// sideways instead of squashing its columns.
class _ScrollableTable extends StatelessWidget {
  const _ScrollableTable({required this.child});

  final Widget child;

  static const double _minWidth = 720;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (BuildContext context, BoxConstraints box) {
      if (box.maxWidth >= _minWidth) return child;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(width: _minWidth, child: child),
      );
    },
  );
}
