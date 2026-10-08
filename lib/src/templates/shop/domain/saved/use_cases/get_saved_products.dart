import '../../catalog/models/product.dart';
import '../../catalog/repositories/product_repository.dart';

/// Resolves saved ids to products, in catalogue order.
///
/// Depends on another feature's *domain* interface, never on its data or
/// presentation layers.
class GetSavedProducts {
  /// Creates the use case.
  const GetSavedProducts(this._products);

  final ProductRepository _products;

  /// Runs it.
  Future<List<Product>> call(Set<String> ids) async {
    final List<Product> all = await _products.getProducts();
    return all.where((Product p) => ids.contains(p.id)).toList();
  }
}
