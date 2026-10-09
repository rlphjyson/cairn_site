import '../models/order.dart';
import '../repositories/orders_repository.dart';

/// Loads every order.
class GetOrders {
  /// Creates the use case.
  const GetOrders(this._repository);

  final OrdersRepository _repository;

  /// Runs it.
  Future<List<Order>> call() => _repository.getOrders();
}
