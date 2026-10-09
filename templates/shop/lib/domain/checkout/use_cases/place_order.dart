import '../../../common/utils/dates.dart';
import '../../cart/models/cart.dart';
import '../../cart/models/delivery_method.dart';
import '../../cart/repositories/cart_repository.dart';
import '../../cart/use_cases/calculate_cart_totals.dart';
import '../../orders/models/order.dart';
import '../../orders/models/shipping_details.dart';
import '../../orders/repositories/order_repository.dart';
import '../models/payment_details.dart';

/// Turns the cart into an order and empties the cart.
///
/// This is where a real shop would charge the card. The template does not: it
/// keeps only the last four digits and records the order locally.
class PlaceOrder {
  /// Creates the use case. [now] is injectable for tests.
  const PlaceOrder(
    this._cart,
    this._orders,
    this._totals, [
    this._now = DateTime.now,
  ]);

  final CartRepository _cart;
  final OrderRepository _orders;
  final CalculateCartTotals _totals;
  final DateTime Function() _now;

  /// Runs it. Returns `null` when the cart is empty.
  Future<Order?> call({
    required ShippingDetails shipping,
    required DeliveryMethod delivery,
    required PaymentDetails payment,
  }) async {
    final Cart cart = await _cart.getCart();
    if (cart.lines.isEmpty) return null;
    final DateTime placedAt = _now();
    final Order order = await _orders.place(
      OrderDraft(
        lines: cart.lines,
        totals: _totals(cart.lines, promo: cart.promo, delivery: delivery),
        shipping: shipping,
        cardLast4: payment.last4,
        promo: cart.promo,
        placedAt: placedAt,
        estimatedDelivery: addBusinessDays(placedAt, delivery.businessDays),
      ),
    );
    await _cart.clear();
    return order;
  }
}
