library;

import 'models/product.dart';

/// Read access to the catalogue plus the one write the checkout needs.
///
/// This is the seam to replace with a real backend (Postgres, Firestore, a
/// headless commerce API). Everything above it only ever sees these methods.
abstract interface class CatalogRepository {
  Future<List<Product>> allProducts();
  Future<Product?> productBySlug(String slug);

  /// A product that used to live at [slug] (for 301s), or `null`.
  Future<Product?> productByPreviousSlug(String slug);
  Future<Product?> productById(String id);
  Future<List<Category>> categories();

  /// Atomically removes stock for every entry, or changes nothing and returns
  /// `false` when any variant lacks stock. A real database does this in a
  /// transaction (`UPDATE ... WHERE stock >= :qty`).
  Future<bool> reserveStock(Map<String, int> quantityByVariantId);
}
