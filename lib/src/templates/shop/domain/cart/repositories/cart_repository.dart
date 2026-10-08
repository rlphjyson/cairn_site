import '../models/cart_line.dart';

/// The shopping cart.
abstract interface class CartRepository {
  /// Every line, in the order products were first added.
  Future<List<CartLine>> getLines();

  /// Adds one of [productId].
  Future<void> add(String productId);

  /// Sets the quantity of [productId]; zero or less removes it.
  Future<void> setQuantity(String productId, int quantity);

  /// Empties the cart.
  Future<void> clear();
}
