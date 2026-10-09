import '../models/order.dart';
import '../repositories/orders_repository.dart';

/// Loads the newest few orders.
class GetRecentOrders {
  /// Creates the use case.
  const GetRecentOrders(this._repository);

  final OrdersRepository _repository;

  /// Runs it.
  Future<List<Order>> call({int limit = 5}) async =>
      (await _repository.getOrders()).take(limit).toList();
}
