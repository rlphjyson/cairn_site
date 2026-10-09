import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/cart/models/cart.dart';
import '../../../domain/cart/models/cart_line.dart';
import '../../../domain/cart/models/cart_totals.dart';
import '../../../domain/cart/models/delivery_method.dart';
import '../../../domain/cart/models/promo_code.dart';
import '../../../domain/cart/use_cases/add_to_cart.dart';
import '../../../domain/cart/use_cases/apply_promo_code.dart';
import '../../../domain/cart/use_cases/calculate_cart_totals.dart';
import '../../../domain/cart/use_cases/get_cart.dart';
import '../../../domain/cart/use_cases/remove_promo_code.dart';
import '../../../domain/cart/use_cases/set_cart_quantity.dart';

/// What is in the cart and what it costs.
class CartState extends Equatable {
  /// Creates a state.
  const CartState({
    this.lines = const <CartLine>[],
    this.promo,
    this.promoError,
    this.totals = CartTotals.empty,
  });

  /// The lines.
  final List<CartLine> lines;

  /// The applied promo code, if any.
  final PromoCode? promo;

  /// Why the last code was rejected, or `null`.
  final String? promoError;

  /// The money, for standard delivery.
  final CartTotals totals;

  /// Whether nothing is in the cart.
  bool get isEmpty => lines.isEmpty;

  /// How many units are in the cart across every line.
  int get itemCount => totals.itemCount;

  /// How many of [productId] are in the cart, across its variants.
  int quantityOf(String productId) => lines
      .where((CartLine l) => l.product.id == productId)
      .fold(0, (int sum, CartLine l) => sum + l.quantity);

  /// How many of the line with [key] are in the cart.
  int quantityOfLine(String key) => lines
      .where((CartLine l) => l.key == key)
      .fold(0, (int sum, CartLine l) => sum + l.quantity);

  @override
  List<Object?> get props => <Object?>[lines, promo, promoError, totals];
}

/// Session-scoped cart state. A lazy singleton: no view model closes it.
class CartCubit extends Cubit<CartState> {
  /// Creates the cubit.
  CartCubit(
    this._getCart,
    this._add,
    this._setQuantity,
    this._applyPromo,
    this._removePromo,
    this._totals,
  ) : super(const CartState());

  final GetCart _getCart;
  final AddToCart _add;
  final SetCartQuantity _setQuantity;
  final ApplyPromoCode _applyPromo;
  final RemovePromoCode _removePromo;
  final CalculateCartTotals _totals;

  /// Reads the cart from the repository.
  Future<void> load() async {
    final Cart cart = await _getCart();
    if (isClosed) return;
    emit(
      CartState(
        lines: cart.lines,
        promo: cart.promo,
        totals: _totals(cart.lines, promo: cart.promo),
      ),
    );
  }

  /// Adds [quantity] of [productId] in [variant].
  Future<void> add(
    String productId, {
    String variant = '',
    int quantity = 1,
  }) async {
    await _add(productId, variant, quantity: quantity);
    await load();
  }

  /// Sets the quantity of the line with [lineKey]; zero removes it.
  Future<void> setQuantity(String lineKey, int quantity) async {
    await _setQuantity(lineKey, quantity);
    await load();
  }

  /// Removes the line with [lineKey].
  Future<void> remove(String lineKey) => setQuantity(lineKey, 0);

  /// Tries a promo code. Returns whether it was accepted; when it is not,
  /// [CartState.promoError] says why.
  Future<bool> applyPromo(String input) async {
    if (input.trim().isEmpty) {
      emit(_withError('Enter a promo code.'));
      return false;
    }
    final PromoCode? promo = await _applyPromo(input);
    if (isClosed) return false;
    if (promo == null) {
      emit(_withError('That code is not valid.'));
      return false;
    }
    await load();
    return true;
  }

  /// Removes the applied promo code.
  Future<void> removePromo() async {
    await _removePromo();
    await load();
  }

  /// The totals as they would be for [delivery].
  CartTotals totalsFor(DeliveryMethod delivery) =>
      _totals(state.lines, promo: state.promo, delivery: delivery);

  CartState _withError(String error) => CartState(
    lines: state.lines,
    promo: state.promo,
    promoError: error,
    totals: state.totals,
  );
}
