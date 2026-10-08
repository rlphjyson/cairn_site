import '../../cart/models/cart_line.dart';
import '../../cart/models/cart_totals.dart';
import '../models/order.dart';

/// Where placed orders go.
abstract interface class OrderRepository {
  /// Records an order for [lines] and returns it.
  Future<Order> place(List<CartLine> lines, CartTotals totals);
}
