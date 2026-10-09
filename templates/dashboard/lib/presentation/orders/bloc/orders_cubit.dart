import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/orders/models/order.dart';
import '../../../domain/orders/use_cases/filter_orders.dart';
import '../../../domain/orders/use_cases/get_orders.dart';

/// What the orders page is showing.
class OrdersState extends Equatable {
  /// Creates a state.
  const OrdersState({
    this.loading = true,
    this.orders = const <Order>[],
    this.visible = const <Order>[],
    this.status,
    this.failed = false,
  });

  /// Whether orders are still loading.
  final bool loading;

  /// Every order.
  final List<Order> orders;

  /// [orders] after the status filter.
  final List<Order> visible;

  /// The selected status, or `null` for all.
  final OrderStatus? status;

  /// Whether the last load failed.
  final bool failed;

  @override
  List<Object?> get props => <Object?>[
    loading,
    orders,
    visible,
    status,
    failed,
  ];
}

/// State for the orders page. Scoped to one visit; its view model closes it.
class OrdersCubit extends Cubit<OrdersState> {
  /// Creates the cubit.
  OrdersCubit(this._getOrders, this._filter) : super(const OrdersState());

  final GetOrders _getOrders;
  final FilterOrders _filter;

  /// Loads the orders.
  Future<void> load() async {
    try {
      final List<Order> orders = await _getOrders();
      if (isClosed) return;
      emit(
        OrdersState(
          loading: false,
          orders: orders,
          visible: _filter(orders, status: state.status),
          status: state.status,
        ),
      );
    } on Object {
      if (isClosed) return;
      emit(
        OrdersState(
          loading: false,
          orders: state.orders,
          visible: state.visible,
          status: state.status,
          failed: true,
        ),
      );
    }
  }

  /// Filters by [status]; `null` shows everything.
  void selectStatus(OrderStatus? status) => emit(
    OrdersState(
      loading: false,
      orders: state.orders,
      visible: _filter(state.orders, status: status),
      status: status,
    ),
  );
}
