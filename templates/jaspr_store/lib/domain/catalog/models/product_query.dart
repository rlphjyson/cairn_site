library;

import 'package:meta/meta.dart';

import 'product.dart';

enum ProductSort {
  featured('featured', 'Featured'),
  newest('newest', 'Newest'),
  priceAsc('price-asc', 'Price: low to high'),
  priceDesc('price-desc', 'Price: high to low'),
  rating('rating', 'Top rated'),
  name('name', 'Name: A to Z');

  const ProductSort(this.param, this.label);

  /// The value used in `?sort=`.
  final String param;
  final String label;

  static const ProductSort defaultSort = ProductSort.featured;

  static ProductSort? parse(String? value) {
    if (value == null) return null;
    for (final s in values) {
      if (s.param == value) return s;
    }
    return null;
  }
}

@immutable
class ProductQuery {
  const ProductQuery({
    this.categorySlug,
    this.search = '',
    this.sort = ProductSort.featured,
    this.page = 1,
    this.pageSize = 8,
    this.inStockOnly = false,
  });

  final String? categorySlug;
  final String search;
  final ProductSort sort;
  final int page;
  final int pageSize;
  final bool inStockOnly;

  String get normalisedSearch => search.trim().replaceAll(RegExp(r'\s+'), ' ');
  bool get hasSearch => normalisedSearch.isNotEmpty;
}

@immutable
class ProductListing {
  const ProductListing({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.query,
  });

  final List<Product> items;

  /// Number of products matching the filters, across all pages.
  final int total;
  final int page;
  final int pageSize;
  final ProductQuery query;

  int get pageCount => total == 0 ? 1 : (total + pageSize - 1) ~/ pageSize;
  bool get hasPrev => page > 1;
  bool get hasNext => page < pageCount;
  bool get pageOutOfRange => total > 0 && page > pageCount;
  bool get isEmpty => total == 0;

  /// 1-based index of the first/last item on this page, for "1-8 of 12".
  int get firstIndex => total == 0 ? 0 : (page - 1) * pageSize + 1;
  int get lastIndex => total == 0 ? 0 : firstIndex + items.length - 1;
}
