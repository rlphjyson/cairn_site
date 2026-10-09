import '../../../common/constants/shipping_policy.dart';
import '../models/cart_line.dart';
import '../models/cart_totals.dart';
import '../models/delivery_method.dart';
import '../models/promo_code.dart';

/// Works out subtotal, discount, shipping and progress to free shipping.
///
/// Pure, so the business rules are tested without a widget or a repository.
/// Free standard shipping is judged on the subtotal *after* the discount, which
/// is what the shopper actually pays for goods.
class CalculateCartTotals {
  /// Creates the use case.
  const CalculateCartTotals();

  /// Runs it.
  CartTotals call(
    List<CartLine> lines, {
    PromoCode? promo,
    DeliveryMethod delivery = DeliveryMethod.standard,
  }) {
    if (lines.isEmpty) return CartTotals.empty;
    final double subtotal = lines.fold(
      0,
      (double sum, CartLine l) => sum + l.total,
    );
    final int count = lines.fold(0, (int sum, CartLine l) => sum + l.quantity);
    final double discount = promo == null
        ? 0
        : (subtotal * promo.percentOff).roundToDouble() / 100;
    final double payable = subtotal - discount;
    const double threshold = ShippingPolicy.freeShippingThreshold;
    final bool freeStandard = payable >= threshold;
    final double shipping = switch (delivery) {
      DeliveryMethod.standard => freeStandard ? 0 : ShippingPolicy.flatRate,
      DeliveryMethod.express => ShippingPolicy.expressRate,
    };
    return CartTotals(
      itemCount: count,
      subtotal: subtotal,
      discount: discount,
      shipping: shipping,
      amountToFreeShipping: freeStandard ? 0 : threshold - payable,
      freeShippingProgress: (payable / threshold).clamp(0.0, 1.0),
      delivery: delivery,
    );
  }
}
