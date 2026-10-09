library;

import 'models/cart.dart';

/// Persistence for carts. The cart *id* is opaque and server-issued; how it is
/// carried to the browser (a signed httpOnly cookie) is an HTTP concern and
/// lives in `lib/backend/cart_cookie.dart`, not here.
abstract interface class CartRepository {
  Future<Cart?> find(String id);
  Future<Cart> create();
  Future<void> save(Cart cart);
  Future<void> delete(String id);
}
