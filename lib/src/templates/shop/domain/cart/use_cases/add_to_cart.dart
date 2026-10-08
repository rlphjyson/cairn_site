import '../repositories/cart_repository.dart';

/// Adds one unit of a product.
class AddToCart {
  /// Creates the use case.
  const AddToCart(this._repository);

  final CartRepository _repository;

  /// Runs it.
  Future<void> call(String productId) => _repository.add(productId);
}
