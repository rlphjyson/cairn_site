import '../../../common/constants/shipping_policy.dart';
import '../models/cart_line.dart';
import '../models/cart_totals.dart';

/// Works out subtotal, shipping and progress to free shipping.
///
/// Pure, so the business rule is tested without a widget or a repository.
class CalculateCartTotals {
  /// Creates the use case.
  const CalculateCartTotals();

  /// Runs it.
  CartTotals call(List<CartLine> lines) {
    if (lines.isEmpty) return CartTotals.empty;
    final double subtotal = lines.fold(
      0,
      (double sum, CartLine l) => sum + l.total,
    );
    final int count = lines.fold(0, (int sum, CartLine l) => sum + l.quantity);
    const double threshold = ShippingPolicy.freeShippingThreshold;
    final bool free = subtotal >= threshold;
    return CartTotals(
      itemCount: count,
      subtotal: subtotal,
      shipping: free ? 0 : ShippingPolicy.flatRate,
      amountToFreeShipping: free ? 0 : threshold - subtotal,
      freeShippingProgress: (subtotal / threshold).clamp(0.0, 1.0),
    );
  }
}
