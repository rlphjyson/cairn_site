import 'package:equatable/equatable.dart';

import '../../catalog/models/product.dart';

/// A product in the cart, with how many.
class CartLine extends Equatable {
  /// Creates a line.
  const CartLine({required this.product, required this.quantity});

  /// What is being bought.
  final Product product;

  /// How many. Always at least one.
  final int quantity;

  /// Price for this line.
  double get total => product.price * quantity;

  @override
  List<Object?> get props => <Object?>[product, quantity];
}
