import '../models/cart.dart';
import '../repositories/cart_repository.dart';

/// Loads the cart.
class GetCart {
  /// Creates the use case.
  const GetCart(this._repository);

  final CartRepository _repository;

  /// Runs it.
  Future<Cart> call() => _repository.getCart();
}
