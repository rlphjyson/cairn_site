import 'package:equatable/equatable.dart';

import '../../cart/models/cart_line.dart';
import '../../cart/models/cart_totals.dart';
import '../../cart/models/promo_code.dart';
import 'order_status.dart';
import 'shipping_details.dart';

/// Everything needed to record an order, before it has a reference number.
class OrderDraft extends Equatable {
  /// Creates a draft.
  const OrderDraft({
    required this.lines,
    required this.totals,
    required this.shipping,
    required this.cardLast4,
    required this.placedAt,
    required this.estimatedDelivery,
    this.promo,
  });

  /// What was bought.
  final List<CartLine> lines;

  /// What it cost, including the delivery method.
  final CartTotals totals;

  /// Where it goes.
  final ShippingDetails shipping;

  /// The last four digits of the card; never the whole number.
  final String cardLast4;

  /// When it was placed.
  final DateTime placedAt;

  /// When it should arrive.
  final DateTime estimatedDelivery;

  /// The promo code used, if any.
  final PromoCode? promo;

  @override
  List<Object?> get props => <Object?>[
    lines,
    totals,
    shipping,
    cardLast4,
    placedAt,
    estimatedDelivery,
    promo,
  ];
}

/// A placed order.
class Order extends Equatable {
  /// Creates an order.
  const Order({
    required this.id,
    required this.lines,
    required this.totals,
    required this.shipping,
    required this.cardLast4,
    required this.placedAt,
    required this.estimatedDelivery,
    this.promo,
    this.status = OrderStatus.processing,
  });

  /// Human-readable reference, e.g. `CR-2048`.
  final String id;

  /// What was bought.
  final List<CartLine> lines;

  /// What it cost.
  final CartTotals totals;

  /// Where it goes.
  final ShippingDetails shipping;

  /// The last four digits of the card paid with.
  final String cardLast4;

  /// When it was placed.
  final DateTime placedAt;

  /// When it should arrive.
  final DateTime estimatedDelivery;

  /// The promo code used, if any.
  final PromoCode? promo;

  /// Progress.
  final OrderStatus status;

  @override
  List<Object?> get props => <Object?>[
    id,
    lines,
    totals,
    shipping,
    cardLast4,
    placedAt,
    estimatedDelivery,
    promo,
    status,
  ];
}
