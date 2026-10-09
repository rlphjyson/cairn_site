import '../models/order.dart';

/// Where orders come from.
abstract interface class OrdersRepository {
  /// Every order, newest first.
  Future<List<Order>> getOrders();
}
