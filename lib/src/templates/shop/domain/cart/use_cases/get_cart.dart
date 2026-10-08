import '../models/cart_line.dart';
import '../repositories/cart_repository.dart';

/// Loads the cart's lines.
class GetCart {
  /// Creates the use case.
  const GetCart(this._repository);

  final CartRepository _repository;

  /// Runs it.
  Future<List<CartLine>> call() => _repository.getLines();
}
