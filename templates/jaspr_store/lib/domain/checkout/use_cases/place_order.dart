library;

import '../../../core/result.dart';
import '../../cart/models/cart.dart';
import '../../cart/use_cases/price_cart.dart';
import '../../catalog/catalog_repository.dart';
import '../models/checkout.dart';
import '../order_repository.dart';
import 'validate_checkout.dart';

/// Places a **demo** order: validates, re-prices from the catalogue, reserves
/// stock, stores the order and returns it. No payment is taken or simulated;
/// see the docs for the Stripe Checkout integration point.
class PlaceOrder {
  const PlaceOrder({required PriceCart priceCart, required this._catalog, required this._orders}) : _price = priceCart;

  final PriceCart _price;
  final CatalogRepository _catalog;
  final OrderRepository _orders;

  Future<Result<Order>> call(Cart cart, CheckoutForm form) async {
    final errors = validateCheckout(form);
    if (errors.isNotEmpty) {
      return Result.err(Failure('invalid_form', 'Please fix the highlighted fields.', fieldErrors: errors));
    }
    final priced = await _price(cart, delivery: form.deliveryMethod);
    if (priced.isEmpty) return const Result.err(Failure('empty_cart', 'Your cart is empty.'));
    if (priced.lines.length != cart.lines.length) {
      return const Result.err(Failure('stale_cart', 'An item in your cart is no longer available.'));
    }
    for (final line in priced.lines) {
      if (line.overStock) {
        return Result.err(
          Failure('out_of_stock', '${line.product.name} (${line.variant.label}) no longer has enough stock.'),
        );
      }
    }
    final reserved = await _catalog.reserveStock({for (final l in priced.lines) l.variant.id: l.quantity});
    if (!reserved) {
      return const Result.err(Failure('out_of_stock', 'Some items just sold out. Please review your cart.'));
    }

    final identity = await _orders.nextIdentity();
    final order = Order(
      id: identity.id,
      number: identity.number,
      createdAt: DateTime.now().toUtc(),
      email: form.email,
      address: ShippingAddress.fromForm(form),
      delivery: priced.delivery,
      lines: [
        for (final l in priced.lines)
          OrderLine(
            productId: l.product.id,
            name: l.product.name,
            variantLabel: l.variant.label,
            sku: l.variant.sku,
            quantity: l.quantity,
            unitCents: l.unitCents,
            imageBase: l.product.primaryImage.base,
          ),
      ],
      subtotalCents: priced.subtotalCents,
      discountCents: priced.discountCents,
      shippingCents: priced.shippingCents,
      promoCode: priced.promoCode,
    );
    await _orders.save(order);
    return Result.ok(order);
  }
}
