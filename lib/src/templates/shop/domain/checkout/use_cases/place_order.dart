import '../../cart/models/cart_line.dart';
import '../../cart/repositories/cart_repository.dart';
import '../../cart/use_cases/calculate_cart_totals.dart';
import '../models/order.dart';
import '../repositories/order_repository.dart';

/// Turns the cart into an order and empties the cart.
class PlaceOrder {
  /// Creates the use case.
  const PlaceOrder(this._cart, this._orders, this._totals);

  final CartRepository _cart;
  final OrderRepository _orders;
  final CalculateCartTotals _totals;

  /// Runs it. Returns `null` when the cart is empty.
  Future<Order?> call() async {
    final List<CartLine> lines = await _cart.getLines();
    if (lines.isEmpty) return null;
    final Order order = await _orders.place(lines, _totals(lines));
    await _cart.clear();
    return order;
  }
}
