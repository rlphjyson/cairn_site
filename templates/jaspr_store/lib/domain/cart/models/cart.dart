library;

import 'package:meta/meta.dart';

import '../../catalog/models/product.dart';

/// What is persisted for a cart line: ids and a quantity, **never a price**.
/// Prices are looked up again every time the cart is read, so nothing a client
/// can send or tamper with ever decides what it pays.
@immutable
class CartLine {
  const CartLine({required this.productId, required this.variantId, required this.quantity});

  final String productId;
  final String variantId;
  final int quantity;

  CartLine withQuantity(int q) => CartLine(productId: productId, variantId: variantId, quantity: q);
}

@immutable
class Cart {
  const Cart({required this.id, this.lines = const [], this.promoCode, required this.updatedAt});

  final String id;
  final List<CartLine> lines;
  final String? promoCode;
  final DateTime updatedAt;

  int get itemCount => lines.fold(0, (s, l) => s + l.quantity);
  bool get isEmpty => lines.isEmpty;

  Cart copyWith({List<CartLine>? lines, String? promoCode, bool clearPromo = false, DateTime? updatedAt}) => Cart(
    id: id,
    lines: lines ?? this.lines,
    promoCode: clearPromo ? null : (promoCode ?? this.promoCode),
    updatedAt: updatedAt ?? this.updatedAt,
  );
}

enum DeliveryMethod {
  standard('standard', 'Standard delivery', '3-5 business days'),
  express('express', 'Express delivery', '1-2 business days');

  const DeliveryMethod(this.id, this.label, this.eta);
  final String id;
  final String label;
  final String eta;

  static DeliveryMethod? parse(String? id) {
    for (final m in values) {
      if (m.id == id) return m;
    }
    return null;
  }
}

@immutable
class PricedLine {
  const PricedLine({
    required this.product,
    required this.variant,
    required this.quantity,
    required this.unitCents,
  });

  final Product product;
  final ProductVariant variant;
  final int quantity;
  final int unitCents;

  int get totalCents => unitCents * quantity;
  int get compareAtTotalCents => (product.compareAtCents ?? unitCents) * quantity;
  bool get overStock => quantity > variant.stock;
}

@immutable
class PricedCart {
  const PricedCart({
    required this.lines,
    required this.subtotalCents,
    required this.discountCents,
    required this.shippingCents,
    required this.delivery,
    required this.freeShippingThresholdCents,
    this.promoCode,
    this.promoLabel,
  });

  final List<PricedLine> lines;
  final int subtotalCents;
  final int discountCents;
  final int shippingCents;
  final DeliveryMethod delivery;
  final int freeShippingThresholdCents;
  final String? promoCode;
  final String? promoLabel;

  int get itemCount => lines.fold(0, (s, l) => s + l.quantity);
  bool get isEmpty => lines.isEmpty;
  int get totalCents => subtotalCents - discountCents + shippingCents;

  /// The amount compared against the free-shipping threshold.
  int get qualifyingCents => subtotalCents - discountCents;
  bool get qualifiesForFreeShipping => qualifyingCents >= freeShippingThresholdCents;
  int get freeShippingRemainingCents => qualifiesForFreeShipping ? 0 : freeShippingThresholdCents - qualifyingCents;

  /// 0.0 - 1.0, for the progress bar.
  double get freeShippingProgress {
    if (freeShippingThresholdCents <= 0) return 1;
    final p = qualifyingCents / freeShippingThresholdCents;
    return p < 0 ? 0 : (p > 1 ? 1 : p);
  }
}
