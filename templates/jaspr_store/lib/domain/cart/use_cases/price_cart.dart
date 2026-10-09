library;

import '../../../common/utils/money.dart';
import '../../../core/config/store_config.dart';
import '../../catalog/catalog_repository.dart';
import '../../catalog/models/product.dart';
import '../models/cart.dart';

/// Pure pricing: given a cart, the products it references and the store's
/// policy, compute every figure the cart and checkout show.
///
/// Order of operations (documented because it is where stores disagree):
///  1. subtotal = sum(unit price x quantity)
///  2. discount = promo percent of subtotal (integer, half-up)
///  3. shipping is free for standard delivery when `subtotal - discount` reaches
///     the threshold; express always costs money.
///  4. total = subtotal - discount + shipping. Prices are tax-inclusive.
PricedCart computePricedCart({
  required Cart cart,
  required Map<String, Product> productsById,
  required StoreConfig config,
  DeliveryMethod delivery = DeliveryMethod.standard,
}) {
  final lines = <PricedLine>[];
  for (final line in cart.lines) {
    final product = productsById[line.productId];
    final variant = product?.variantById(line.variantId);
    if (product == null || variant == null) continue; // product was removed from the catalogue
    lines.add(
      PricedLine(product: product, variant: variant, quantity: line.quantity, unitCents: product.priceFor(variant)),
    );
  }

  final subtotal = lines.fold<int>(0, (s, l) => s + l.totalCents);
  final promo = cart.promoCode == null ? null : config.findPromo(cart.promoCode!);
  final discount = promo == null ? 0 : percentOf(subtotal, promo.percentOff);
  final qualifying = subtotal - discount;
  final policy = config.shipping;

  final int shipping;
  if (lines.isEmpty) {
    shipping = 0;
  } else if (delivery == DeliveryMethod.express) {
    shipping = policy.expressCents;
  } else {
    shipping = qualifying >= policy.freeThresholdCents ? 0 : policy.standardCents;
  }

  return PricedCart(
    lines: lines,
    subtotalCents: subtotal,
    discountCents: discount,
    shippingCents: shipping,
    delivery: delivery,
    freeShippingThresholdCents: policy.freeThresholdCents,
    promoCode: promo?.code,
    promoLabel: promo?.label,
  );
}

class PriceCart {
  const PriceCart(this._catalog, this._config);
  final CatalogRepository _catalog;
  final StoreConfig _config;

  Future<PricedCart> call(Cart cart, {DeliveryMethod delivery = DeliveryMethod.standard}) async {
    final products = await _catalog.allProducts();
    return computePricedCart(
      cart: cart,
      productsById: {for (final p in products) p.id: p},
      config: _config,
      delivery: delivery,
    );
  }
}
