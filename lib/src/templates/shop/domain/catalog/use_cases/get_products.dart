import '../models/product.dart';
import '../repositories/product_repository.dart';

/// Loads the whole catalogue.
class GetProducts {
  /// Creates the use case.
  const GetProducts(this._repository);

  final ProductRepository _repository;

  /// Runs it.
  Future<List<Product>> call() => _repository.getProducts();
}
