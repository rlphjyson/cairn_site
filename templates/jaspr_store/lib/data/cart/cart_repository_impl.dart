library;

import '../../backend/stores.dart';
import '../../domain/cart/cart_repository.dart';
import '../../domain/cart/models/cart.dart';

class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl(this._store);
  final CartStore _store;

  @override
  Future<Cart?> find(String id) async => _store.find(id);

  @override
  Future<Cart> create() async => _store.create();

  @override
  Future<void> save(Cart cart) async => _store.save(cart);

  @override
  Future<void> delete(String id) async => _store.delete(id);
}
