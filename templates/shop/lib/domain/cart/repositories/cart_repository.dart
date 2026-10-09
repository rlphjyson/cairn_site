import '../models/cart.dart';
import '../models/promo_code.dart';

/// The shopping cart.
abstract interface class CartRepository {
  /// The lines and the applied promo code.
  Future<Cart> getCart();

  /// Adds [quantity] of [productId] in [variant], merging into an existing
  /// line for the same product and variant.
  Future<void> add(String productId, String variant, int quantity);

  /// Sets the quantity of the line with [lineKey]; zero or less removes it.
  Future<void> setQuantity(String lineKey, int quantity);

  /// Applies [promo], or removes the current code when `null`.
  Future<void> setPromo(PromoCode? promo);

  /// Empties the cart and drops its promo code.
  Future<void> clear();
}
