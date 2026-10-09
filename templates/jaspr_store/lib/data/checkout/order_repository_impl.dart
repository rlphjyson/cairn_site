library;

import '../../backend/stores.dart';
import '../../domain/checkout/models/checkout.dart';
import '../../domain/checkout/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl(this._store);
  final OrderStore _store;

  @override
  Future<({String id, String number})> nextIdentity() async => _store.nextIdentity();

  @override
  Future<void> save(Order order) async => _store.save(order);

  @override
  Future<Order?> byId(String id) async => _store.byId(id);
}
