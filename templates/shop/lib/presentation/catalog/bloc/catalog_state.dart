import 'package:equatable/equatable.dart';

import '../../../common/constants/product_categories.dart';
import '../../../domain/catalog/models/product.dart';
import '../../../domain/catalog/models/product_sort.dart';

/// Whether the catalogue has arrived.
enum CatalogStatus {
  /// Fetching; the storefront shows skeletons.
  loading,

  /// Loaded.
  ready,

  /// The fetch failed; the storefront offers a retry.
  failed,
}

/// What the storefront is showing.
class CatalogState extends Equatable {
  /// Creates a state.
  const CatalogState({
    this.status = CatalogStatus.loading,
    this.products = const <Product>[],
    this.visible = const <Product>[],
    this.featured = const <Product>[],
    this.newArrivals = const <Product>[],
    this.category = ProductCategories.all,
    this.query = '',
    this.sort = ProductSort.popular,
  });

  /// Progress of the fetch.
  final CatalogStatus status;

  /// The full catalogue.
  final List<Product> products;

  /// [products] after the category and query are applied, then sorted.
  final List<Product> visible;

  /// The best-rated products, for the Featured row.
  final List<Product> featured;

  /// Products flagged as new, for the New arrivals grid.
  final List<Product> newArrivals;

  /// The selected chip.
  final String category;

  /// The search text.
  final String query;

  /// The selected sort order.
  final ProductSort sort;

  /// Whether the shopper has narrowed the list; the storefront then shows one
  /// results grid instead of its curated sections.
  bool get isFiltering =>
      category != ProductCategories.all || query.trim().isNotEmpty;

  /// Whether the catalogue is still loading.
  bool get loading => status == CatalogStatus.loading;

  /// A copy with the given fields replaced.
  CatalogState copyWith({
    CatalogStatus? status,
    List<Product>? products,
    List<Product>? visible,
    List<Product>? featured,
    List<Product>? newArrivals,
    String? category,
    String? query,
    ProductSort? sort,
  }) => CatalogState(
    status: status ?? this.status,
    products: products ?? this.products,
    visible: visible ?? this.visible,
    featured: featured ?? this.featured,
    newArrivals: newArrivals ?? this.newArrivals,
    category: category ?? this.category,
    query: query ?? this.query,
    sort: sort ?? this.sort,
  );

  @override
  List<Object?> get props => <Object?>[
    status,
    products,
    visible,
    featured,
    newArrivals,
    category,
    query,
    sort,
  ];
}
