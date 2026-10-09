import '../models/product.dart';
import '../models/product_sort.dart';

/// Orders a product list. Never mutates its input; ties keep catalogue order.
class SortProducts {
  /// Creates the use case.
  const SortProducts();

  /// Runs it.
  List<Product> call(List<Product> products, ProductSort sort) {
    final List<(int, Product)> indexed = <(int, Product)>[
      for (int i = 0; i < products.length; i++) (i, products[i]),
    ];
    int compare(Product a, Product b) => switch (sort) {
      ProductSort.popular => b.ratingCount.compareTo(a.ratingCount),
      ProductSort.priceLowHigh => a.price.compareTo(b.price),
      ProductSort.priceHighLow => b.price.compareTo(a.price),
      ProductSort.topRated =>
        b.rating != a.rating
            ? b.rating.compareTo(a.rating)
            : b.ratingCount.compareTo(a.ratingCount),
    };
    indexed.sort(((int, Product) a, (int, Product) b) {
      final int c = compare(a.$2, b.$2);
      return c != 0 ? c : a.$1.compareTo(b.$1);
    });
    return <Product>[for (final (int, Product) e in indexed) e.$2];
  }
}
