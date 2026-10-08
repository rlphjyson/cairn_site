import 'package:equatable/equatable.dart';

import '../../cart/models/cart_line.dart';
import '../../cart/models/cart_totals.dart';

/// A placed order.
class Order extends Equatable {
  /// Creates an order.
  const Order({
    required this.id,
    required this.lines,
    required this.totals,
    required this.placedAt,
  });

  /// Human-readable reference, e.g. `CR-2048`.
  final String id;

  /// What was bought.
  final List<CartLine> lines;

  /// What it cost.
  final CartTotals totals;

  /// When it was placed.
  final DateTime placedAt;

  @override
  List<Object?> get props => <Object?>[id, lines, totals, placedAt];
}
