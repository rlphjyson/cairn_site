import '../models/order.dart';

/// Narrows orders by status. `null` keeps everything.
///
/// Pure and synchronous, so it is tested without a widget.
class FilterOrders {
  /// Creates the use case.
  const FilterOrders();

  /// Runs it.
  List<Order> call(List<Order> orders, {OrderStatus? status}) => status == null
      ? orders
      : orders.where((Order o) => o.status == status).toList();
}
