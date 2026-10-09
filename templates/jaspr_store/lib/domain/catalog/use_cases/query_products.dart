library;

import '../catalog_repository.dart';
import '../models/product.dart';
import '../models/product_query.dart';

/// Filters, searches, sorts and paginates the catalogue.
///
/// The work is a pure function ([applyQuery]) over a list so it is trivially
/// unit-testable; the use case only adds the repository read. With a real
/// database you would push the same logic into SQL and keep this signature.
class QueryProducts {
  const QueryProducts(this._catalog);
  final CatalogRepository _catalog;

  Future<ProductListing> call(ProductQuery query) async {
    final categories = await _catalog.categories();
    final products = await _catalog.allProducts();
    return applyQuery(products, query, categories: categories);
  }
}

ProductListing applyQuery(List<Product> products, ProductQuery query, {List<Category> categories = const []}) {
  var list = products.where((p) => query.categorySlug == null || p.categorySlug == query.categorySlug).toList();
  if (query.inStockOnly) list = list.where((p) => p.inStock).toList();

  final categoryNames = {for (final c in categories) c.slug: c.name};
  final terms = _terms(query.search);
  final scores = <String, int>{};
  if (terms.isNotEmpty) {
    list = list.where((p) {
      final score = _score(p, terms, categoryNames[p.categorySlug] ?? '');
      if (score <= 0) return false;
      scores[p.id] = score;
      return true;
    }).toList();
  }

  int byFeatured(Product a, Product b) {
    if (a.featured != b.featured) return a.featured ? -1 : 1;
    return a.name.compareTo(b.name);
  }

  switch (query.sort) {
    case ProductSort.featured:
      // When searching, relevance beats the featured flag.
      list.sort((a, b) {
        if (terms.isNotEmpty) {
          final c = (scores[b.id] ?? 0).compareTo(scores[a.id] ?? 0);
          if (c != 0) return c;
        }
        return byFeatured(a, b);
      });
    case ProductSort.newest:
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    case ProductSort.priceAsc:
      list.sort((a, b) => a.priceCents.compareTo(b.priceCents));
    case ProductSort.priceDesc:
      list.sort((a, b) => b.priceCents.compareTo(a.priceCents));
    case ProductSort.rating:
      list.sort((a, b) {
        final c = b.rating.average.compareTo(a.rating.average);
        return c != 0 ? c : b.rating.count.compareTo(a.rating.count);
      });
    case ProductSort.name:
      list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  final total = list.length;
  final pageSize = query.pageSize < 1 ? 1 : query.pageSize;
  final page = query.page < 1 ? 1 : query.page;
  final start = (page - 1) * pageSize;
  final items = start >= total ? <Product>[] : list.skip(start).take(pageSize).toList();
  return ProductListing(items: items, total: total, page: page, pageSize: pageSize, query: query);
}

List<String> _terms(String search) =>
    search.toLowerCase().split(RegExp(r'[^a-z0-9]+')).where((t) => t.isNotEmpty).toList();

/// Every term must match somewhere (AND semantics). Name hits weigh most.
int _score(Product p, List<String> terms, String categoryName) {
  final name = p.name.toLowerCase();
  final brand = p.brand.toLowerCase();
  final category = categoryName.toLowerCase();
  final tags = p.tags.map((t) => t.toLowerCase()).toList();
  final body = '${p.summary} ${p.description.join(' ')}'.toLowerCase();
  var total = 0;
  for (final term in terms) {
    var s = 0;
    if (name.contains(term)) s += 10;
    if (brand.contains(term)) s += 5;
    if (category.contains(term)) s += 4;
    if (tags.any((t) => t.contains(term))) s += 6;
    if (body.contains(term)) s += 2;
    if (p.sku.toLowerCase().contains(term)) s += 8;
    if (s == 0) return 0;
    total += s;
  }
  return total;
}
