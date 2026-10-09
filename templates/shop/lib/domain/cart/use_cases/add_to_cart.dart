import '../repositories/cart_repository.dart';

/// Adds a product in a chosen variant.
class AddToCart {
  /// Creates the use case.
  const AddToCart(this._repository);

  final CartRepository _repository;

  /// Runs it. [quantity] below one adds nothing.
  Future<void> call(String productId, String variant, {int quantity = 1}) {
    if (quantity < 1) return Future<void>.value();
    return _repository.add(productId, variant, quantity);
  }
}
