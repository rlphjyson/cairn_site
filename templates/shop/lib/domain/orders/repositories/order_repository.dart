import '../models/order.dart';

/// Where placed orders go.
abstract interface class OrderRepository {
  /// Every order, newest first.
  Future<List<Order>> getOrders();

  /// Records [draft] and returns the order with its reference number.
  Future<Order> place(OrderDraft draft);
}
