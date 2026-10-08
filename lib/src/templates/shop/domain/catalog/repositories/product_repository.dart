import '../models/product.dart';

/// Where products come from. The domain depends on this interface; the data
/// layer provides the implementation.
abstract interface class ProductRepository {
  /// Every product, in display order.
  Future<List<Product>> getProducts();

  /// One product, or `null` when [id] is unknown.
  Future<Product?> getProduct(String id);
}
