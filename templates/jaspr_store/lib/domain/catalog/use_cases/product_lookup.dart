library;

import '../../../common/constants.dart';
import '../catalog_repository.dart';
import '../models/product.dart';

sealed class SlugResolution {
  const SlugResolution();
}

class SlugFound extends SlugResolution {
  const SlugFound(this.product);
  final Product product;
}

/// The slug is an old one: answer 301 to [product]'s current URL.
class SlugMoved extends SlugResolution {
  const SlugMoved(this.product);
  final Product product;
}

class SlugNotFound extends SlugResolution {
  const SlugNotFound();
}

/// Resolves a URL slug to a product, a permanent redirect, or a 404.
class ResolveProductSlug {
  const ResolveProductSlug(this._catalog);
  final CatalogRepository _catalog;

  Future<SlugResolution> call(String slug) async {
    final current = await _catalog.productBySlug(slug);
    if (current != null) return SlugFound(current);
    final moved = await _catalog.productByPreviousSlug(slug);
    if (moved != null) return SlugMoved(moved);
    return const SlugNotFound();
  }
}

class GetCategories {
  const GetCategories(this._catalog);
  final CatalogRepository _catalog;
  Future<List<Category>> call() => _catalog.categories();
}

class GetFeaturedProducts {
  const GetFeaturedProducts(this._catalog);
  final CatalogRepository _catalog;

  Future<List<Product>> call({int limit = 4}) async {
    final all = await _catalog.allProducts();
    final featured = all.where((p) => p.featured && p.inStock).toList()..sort((a, b) => a.name.compareTo(b.name));
    return featured.take(limit).toList();
  }
}

/// Same category first, then by tag overlap, then rating. Never the product itself.
class GetRelatedProducts {
  const GetRelatedProducts(this._catalog);
  final CatalogRepository _catalog;

  Future<List<Product>> call(Product product, {int limit = kRelatedProductCount}) async {
    final all = await _catalog.allProducts();
    final candidates = all.where((p) => p.id != product.id).toList();
    int score(Product p) {
      var s = p.categorySlug == product.categorySlug ? 100 : 0;
      s += p.tags.where(product.tags.contains).length * 10;
      s += p.inStock ? 5 : 0;
      return s;
    }

    candidates.sort((a, b) {
      final c = score(b).compareTo(score(a));
      if (c != 0) return c;
      final r = b.rating.average.compareTo(a.rating.average);
      return r != 0 ? r : a.name.compareTo(b.name);
    });
    return candidates.take(limit).toList();
  }
}
