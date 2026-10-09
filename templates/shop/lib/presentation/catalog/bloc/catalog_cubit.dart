import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/catalog/models/product.dart';
import '../../../domain/catalog/models/product_sort.dart';
import '../../../domain/catalog/use_cases/filter_products.dart';
import '../../../domain/catalog/use_cases/get_products.dart';
import '../../../domain/catalog/use_cases/sort_products.dart';
import 'catalog_state.dart';

/// State for the storefront: the catalogue plus its filters and sort order.
///
/// A session cubit, so the shopper's filters survive opening a product and
/// coming back.
class CatalogCubit extends Cubit<CatalogState> {
  /// Creates the cubit.
  CatalogCubit(this._getProducts, this._filter, this._sort)
    : super(const CatalogState());

  final GetProducts _getProducts;
  final FilterProducts _filter;
  final SortProducts _sort;

  /// How many products the Featured row shows.
  static const int featuredCount = 5;

  /// How many products the New arrivals grid shows.
  static const int newArrivalsCount = 4;

  /// Loads the catalogue, showing skeletons until it arrives.
  Future<void> load() async {
    if (state.status != CatalogStatus.loading) {
      emit(state.copyWith(status: CatalogStatus.loading));
    }
    try {
      final List<Product> products = await _getProducts();
      if (isClosed) return;
      emit(
        _derive(
          state.copyWith(status: CatalogStatus.ready, products: products),
        ),
      );
    } on Object {
      if (isClosed) return;
      emit(state.copyWith(status: CatalogStatus.failed));
    }
  }

  /// Selects a category chip.
  void selectCategory(String category) =>
      emit(_derive(state.copyWith(category: category)));

  /// Applies a search query.
  void search(String query) => emit(_derive(state.copyWith(query: query)));

  /// Changes the sort order.
  void sortBy(ProductSort sort) => emit(_derive(state.copyWith(sort: sort)));

  /// Clears the category and the search, keeping the sort order.
  void clearFilters() =>
      emit(_derive(state.copyWith(category: 'All', query: '')));

  CatalogState _derive(CatalogState s) => s.copyWith(
    visible: _sort(
      _filter(s.products, category: s.category, query: s.query),
      s.sort,
    ),
    featured: _sort(
      s.products,
      ProductSort.topRated,
    ).take(featuredCount).toList(),
    newArrivals: _sort(
      s.products.where((Product p) => p.isNew).toList(),
      ProductSort.popular,
    ).take(newArrivalsCount).toList(),
  );
}
