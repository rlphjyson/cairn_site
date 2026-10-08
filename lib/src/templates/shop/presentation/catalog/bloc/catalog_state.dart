import 'package:equatable/equatable.dart';

import '../../../common/constants/product_categories.dart';
import '../../../domain/catalog/models/product.dart';

/// What the storefront is showing.
class CatalogState extends Equatable {
  /// Creates a state.
  const CatalogState({
    this.loading = true,
    this.products = const <Product>[],
    this.visible = const <Product>[],
    this.category = ProductCategories.all,
    this.query = '',
  });

  /// Whether the catalogue is still loading.
  final bool loading;

  /// The full catalogue.
  final List<Product> products;

  /// [products] after the category and query are applied.
  final List<Product> visible;

  /// The selected chip.
  final String category;

  /// The search text.
  final String query;

  /// A copy with the given fields replaced.
  CatalogState copyWith({
    bool? loading,
    List<Product>? products,
    List<Product>? visible,
    String? category,
    String? query,
  }) => CatalogState(
    loading: loading ?? this.loading,
    products: products ?? this.products,
    visible: visible ?? this.visible,
    category: category ?? this.category,
    query: query ?? this.query,
  );

  @override
  List<Object?> get props => <Object?>[
    loading,
    products,
    visible,
    category,
    query,
  ];
}
