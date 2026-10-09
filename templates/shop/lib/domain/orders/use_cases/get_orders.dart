import '../models/order.dart';
import '../repositories/order_repository.dart';

/// Loads the shopper's orders, newest first.
class GetOrders {
  /// Creates the use case.
  const GetOrders(this._repository);

  final OrderRepository _repository;

  /// Runs it.
  Future<List<Order>> call() => _repository.getOrders();
}
