import 'package:equatable/equatable.dart';

import 'cart_line.dart';
import 'promo_code.dart';

/// The cart's contents: its lines and the promo code applied to them.
class Cart extends Equatable {
  /// Creates a cart.
  const Cart({this.lines = const <CartLine>[], this.promo});

  /// The lines, in the order they were first added.
  final List<CartLine> lines;

  /// The applied code, if any.
  final PromoCode? promo;

  @override
  List<Object?> get props => <Object?>[lines, promo];
}
