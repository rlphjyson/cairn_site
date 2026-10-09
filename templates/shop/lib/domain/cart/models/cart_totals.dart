import 'package:equatable/equatable.dart';

import 'delivery_method.dart';

/// The money for a cart.
class CartTotals extends Equatable {
  /// Creates totals.
  const CartTotals({
    required this.itemCount,
    required this.subtotal,
    required this.discount,
    required this.shipping,
    required this.amountToFreeShipping,
    required this.freeShippingProgress,
    this.delivery = DeliveryMethod.standard,
  });

  /// No items, no money.
  static const CartTotals empty = CartTotals(
    itemCount: 0,
    subtotal: 0,
    discount: 0,
    shipping: 0,
    amountToFreeShipping: 0,
    freeShippingProgress: 0,
  );

  /// Units in the cart.
  final int itemCount;

  /// Sum of the lines.
  final double subtotal;

  /// What a promo code takes off [subtotal]; zero without one.
  final double discount;

  /// Shipping charge for [delivery]; zero when free.
  final double shipping;

  /// How much more to spend for free standard shipping; zero when already free.
  final double amountToFreeShipping;

  /// 0 to 1, how close the discounted subtotal is to the free-shipping
  /// threshold.
  final double freeShippingProgress;

  /// The delivery method [shipping] was priced for.
  final DeliveryMethod delivery;

  /// What is left to pay: subtotal, less the discount, plus shipping.
  double get total => subtotal - discount + shipping;

  @override
  List<Object?> get props => <Object?>[
    itemCount,
    subtotal,
    discount,
    shipping,
    amountToFreeShipping,
    freeShippingProgress,
    delivery,
  ];
}
