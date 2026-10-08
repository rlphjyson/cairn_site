import '../repositories/cart_repository.dart';

/// Sets how many of a product are in the cart.
class SetCartQuantity {
  /// Creates the use case.
  const SetCartQuantity(this._repository);

  final CartRepository _repository;

  /// Runs it. A quantity of zero or less removes the line.
  Future<void> call(String productId, int quantity) =>
      _repository.setQuantity(productId, quantity);
}
