import 'package:equatable/equatable.dart';

import '../../catalog/models/product.dart';

/// The most of one line a shopper can buy at once.
const int maxLineQuantity = 10;

/// A product in the cart, in one variant, with how many.
///
/// The same product in two variants is two lines.
class CartLine extends Equatable {
  /// Creates a line.
  const CartLine({
    required this.product,
    required this.quantity,
    this.variant = '',
  });

  /// What is being bought.
  final Product product;

  /// The chosen variant, e.g. `42 / Red`. Empty when the product has none.
  final String variant;

  /// How many. Always at least one.
  final int quantity;

  /// Identifies the line: the product plus its variant.
  String get key => lineKey(product.id, variant);

  /// Builds a line key without a [CartLine].
  static String lineKey(String productId, String variant) =>
      '$productId|$variant';

  /// Price for this line.
  double get total => product.price * quantity;

  /// What the line would have cost before any markdown.
  double get compareTotal =>
      (product.compareAtPrice ?? product.price) * quantity;

  /// The most the stepper may go to: stock, capped at [maxLineQuantity].
  int get maxQuantity =>
      product.stock < maxLineQuantity ? product.stock : maxLineQuantity;

  @override
  List<Object?> get props => <Object?>[product, variant, quantity];
}
