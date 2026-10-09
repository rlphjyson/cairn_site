import '../repositories/cart_repository.dart';

/// Removes the promo code from the cart.
class RemovePromoCode {
  /// Creates the use case.
  const RemovePromoCode(this._repository);

  final CartRepository _repository;

  /// Runs it.
  Future<void> call() => _repository.setPromo(null);
}
