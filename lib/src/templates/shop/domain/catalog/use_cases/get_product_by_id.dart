import '../models/product.dart';
import '../repositories/product_repository.dart';

/// Loads one product.
class GetProductById {
  /// Creates the use case.
  const GetProductById(this._repository);

  final ProductRepository _repository;

  /// Runs it.
  Future<Product?> call(String id) => _repository.getProduct(id);
}
