import '../models/product.dart';
import '../models/product_sort.dart';
import 'sort_products.dart';

/// Picks products to suggest: same category first, then the best rated.
///
/// Pure, so it serves the product page, the empty cart and the empty saved
/// list alike.
class RecommendProducts {
  /// Creates the use case.
  const RecommendProducts([this._sort = const SortProducts()]);

  final SortProducts _sort;

  /// Runs it. [exclude] are product ids to leave out; [category] is preferred.
  List<Product> call(
    List<Product> all, {
    Set<String> exclude = const <String>{},
    String? category,
    int limit = 6,
  }) {
    final List<Product> pool = _sort(
      all.where((Product p) => !exclude.contains(p.id)).toList(),
      ProductSort.topRated,
    );
    final List<Product> same = <Product>[
      if (category != null)
        ...pool.where((Product p) => p.category == category),
    ];
    final List<Product> rest = pool
        .where((Product p) => !same.contains(p))
        .toList();
    return <Product>[...same, ...rest].take(limit).toList();
  }
}
