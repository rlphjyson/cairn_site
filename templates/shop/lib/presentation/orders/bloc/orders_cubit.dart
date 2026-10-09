import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/orders/models/order.dart';
import '../../../domain/orders/models/shipping_details.dart';
import '../../../domain/orders/use_cases/get_orders.dart';
import '../../../domain/orders/use_cases/get_saved_addresses.dart';

/// The shopper's orders and the addresses they have used.
class OrdersState extends Equatable {
  /// Creates a state.
  const OrdersState({
    this.orders = const <Order>[],
    this.addresses = const <ShippingDetails>[],
  });

  /// Every order, newest first.
  final List<Order> orders;

  /// Distinct shipping addresses, most recent first.
  final List<ShippingDetails> addresses;

  /// The order with [id], or `null`.
  Order? byId(String id) {
    for (final Order o in orders) {
      if (o.id == id) return o;
    }
    return null;
  }

  @override
  List<Object?> get props => <Object?>[orders, addresses];
}

/// Session-scoped order history. A lazy singleton.
class OrdersCubit extends Cubit<OrdersState> {
  /// Creates the cubit.
  OrdersCubit(this._getOrders, this._getAddresses) : super(const OrdersState());

  final GetOrders _getOrders;
  final GetSavedAddresses _getAddresses;

  /// Reads the orders.
  Future<void> load() async {
    final List<Order> orders = await _getOrders();
    if (isClosed) return;
    emit(OrdersState(orders: orders, addresses: _getAddresses(orders)));
  }
}
