import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/catalog/models/product.dart';
import '../../../domain/catalog/use_cases/filter_products.dart';
import '../../../domain/catalog/use_cases/get_products.dart';
import 'catalog_state.dart';

/// State for the storefront: the catalogue plus its filters.
///
/// Scoped to one visit of the screen; its view model closes it.
class CatalogCubit extends Cubit<CatalogState> {
  /// Creates the cubit.
  CatalogCubit(this._getProducts, this._filter) : super(const CatalogState());

  final GetProducts _getProducts;
  final FilterProducts _filter;

  /// Loads the catalogue.
  Future<void> load() async {
    final List<Product> products = await _getProducts();
    if (isClosed) return;
    emit(
      state.copyWith(
        loading: false,
        products: products,
        visible: _filter(
          products,
          category: state.category,
          query: state.query,
        ),
      ),
    );
  }

  /// Selects a category chip.
  void selectCategory(String category) => emit(
    state.copyWith(
      category: category,
      visible: _filter(state.products, category: category, query: state.query),
    ),
  );

  /// Applies a search query.
  void search(String query) => emit(
    state.copyWith(
      query: query,
      visible: _filter(state.products, category: state.category, query: query),
    ),
  );
}
