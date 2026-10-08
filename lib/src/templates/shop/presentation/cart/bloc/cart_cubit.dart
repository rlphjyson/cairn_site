import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/cart/models/cart_line.dart';
import '../../../domain/cart/models/cart_totals.dart';
import '../../../domain/cart/use_cases/add_to_cart.dart';
import '../../../domain/cart/use_cases/calculate_cart_totals.dart';
import '../../../domain/cart/use_cases/get_cart.dart';
import '../../../domain/cart/use_cases/set_cart_quantity.dart';

/// What is in the cart and what it costs.
class CartState extends Equatable {
  /// Creates a state.
  const CartState({
    this.lines = const <CartLine>[],
    this.totals = CartTotals.empty,
  });

  /// The lines.
  final List<CartLine> lines;

  /// The money.
  final CartTotals totals;

  /// Whether nothing is in the cart.
  bool get isEmpty => lines.isEmpty;

  /// How many of [productId] are in the cart.
  int quantityOf(String productId) {
    for (final CartLine l in lines) {
      if (l.product.id == productId) return l.quantity;
    }
    return 0;
  }

  @override
  List<Object?> get props => <Object?>[lines, totals];
}

/// Session-scoped cart state. A lazy singleton: no view model closes it.
class CartCubit extends Cubit<CartState> {
  /// Creates the cubit.
  CartCubit(this._getCart, this._add, this._setQuantity, this._totals)
    : super(const CartState());

  final GetCart _getCart;
  final AddToCart _add;
  final SetCartQuantity _setQuantity;
  final CalculateCartTotals _totals;

  /// Reads the cart from the repository.
  Future<void> load() async {
    final List<CartLine> lines = await _getCart();
    if (isClosed) return;
    emit(CartState(lines: lines, totals: _totals(lines)));
  }

  /// Adds one unit of [productId].
  Future<void> add(String productId) async {
    await _add(productId);
    await load();
  }

  /// Sets the quantity of [productId]; zero removes it.
  Future<void> setQuantity(String productId, int quantity) async {
    await _setQuantity(productId, quantity);
    await load();
  }
}
