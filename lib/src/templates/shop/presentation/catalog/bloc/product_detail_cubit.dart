import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/catalog/models/product.dart';
import '../../../domain/catalog/use_cases/get_product_by_id.dart';

/// What the product page is showing.
class ProductDetailState extends Equatable {
  /// Creates a state.
  const ProductDetailState({this.product, this.option});

  /// The product, once loaded.
  final Product? product;

  /// The selected variant.
  final String? option;

  @override
  List<Object?> get props => <Object?>[product, option];
}

/// State for the product page: the loaded product and the chosen variant.
class ProductDetailCubit extends Cubit<ProductDetailState> {
  /// Creates the cubit.
  ProductDetailCubit(this._getProductById) : super(const ProductDetailState());

  final GetProductById _getProductById;

  /// Loads the product and selects its first option.
  Future<void> load(String id) async {
    final Product? product = await _getProductById(id);
    if (isClosed || product == null) return;
    emit(ProductDetailState(product: product, option: product.options.first));
  }

  /// Chooses a variant.
  void selectOption(String option) =>
      emit(ProductDetailState(product: state.product, option: option));
}
