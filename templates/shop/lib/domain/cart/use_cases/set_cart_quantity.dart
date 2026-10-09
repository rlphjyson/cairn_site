import '../repositories/cart_repository.dart';

/// Sets how many of one cart line there are.
class SetCartQuantity {
  /// Creates the use case.
  const SetCartQuantity(this._repository);

  final CartRepository _repository;

  /// Runs it. A quantity of zero or less removes the line.
  Future<void> call(String lineKey, int quantity) =>
      _repository.setQuantity(lineKey, quantity);
}
