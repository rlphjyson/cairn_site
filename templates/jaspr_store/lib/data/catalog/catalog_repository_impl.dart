library;

import '../../backend/stores.dart';
import '../../domain/catalog/catalog_repository.dart';
import '../../domain/catalog/models/product.dart';
import '../../domain/reviews/models/review.dart';

/// Adapts the in-memory [CatalogStore] to the domain interface, joining review
/// summaries onto each product. Replace this class (and `lib/backend/`) with a
/// database-backed implementation; nothing above `domain/` needs to change.
class CatalogRepositoryImpl implements CatalogRepository {
  CatalogRepositoryImpl(this._catalog, this._reviews);

  final CatalogStore _catalog;
  final ReviewStore _reviews;

  Product _withRating(Product p) =>
      p.copyWith(rating: RatingSummary.from(_reviews.reviews.where((r) => r.productId == p.id)));

  @override
  Future<List<Product>> allProducts() async => _catalog.products.map(_withRating).toList();

  @override
  Future<Product?> productBySlug(String slug) async {
    for (final p in _catalog.products) {
      if (p.slug == slug) return _withRating(p);
    }
    return null;
  }

  @override
  Future<Product?> productByPreviousSlug(String slug) async {
    for (final p in _catalog.products) {
      if (p.previousSlugs.contains(slug)) return _withRating(p);
    }
    return null;
  }

  @override
  Future<Product?> productById(String id) async {
    for (final p in _catalog.products) {
      if (p.id == id) return _withRating(p);
    }
    return null;
  }

  @override
  Future<List<Category>> categories() async => _catalog.categories;

  @override
  Future<bool> reserveStock(Map<String, int> quantityByVariantId) async => _catalog.reserve(quantityByVariantId);
}
