import 'package:equatable/equatable.dart';

/// The money for a cart.
class CartTotals extends Equatable {
  /// Creates totals.
  const CartTotals({
    required this.itemCount,
    required this.subtotal,
    required this.shipping,
    required this.amountToFreeShipping,
    required this.freeShippingProgress,
  });

  /// No items, no money.
  static const CartTotals empty = CartTotals(
    itemCount: 0,
    subtotal: 0,
    shipping: 0,
    amountToFreeShipping: 0,
    freeShippingProgress: 0,
  );

  /// Units in the cart.
  final int itemCount;

  /// Sum of the lines.
  final double subtotal;

  /// Shipping charge; zero when free.
  final double shipping;

  /// How much more to spend for free shipping; zero when already free.
  final double amountToFreeShipping;

  /// 0 to 1, how close the subtotal is to the free-shipping threshold.
  final double freeShippingProgress;

  /// Subtotal plus shipping.
  double get total => subtotal + shipping;

  @override
  List<Object?> get props => <Object?>[
    itemCount,
    subtotal,
    shipping,
    amountToFreeShipping,
    freeShippingProgress,
  ];
}
