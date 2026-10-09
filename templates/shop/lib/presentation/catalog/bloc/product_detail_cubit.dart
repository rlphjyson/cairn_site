import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/cart/models/cart_line.dart';
import '../../../domain/catalog/models/product.dart';
import '../../../domain/catalog/use_cases/get_product_by_id.dart';
import '../../../domain/catalog/use_cases/get_products.dart';
import '../../../domain/catalog/use_cases/recommend_products.dart';

/// What the product page is showing.
class ProductDetailState extends Equatable {
  /// Creates a state.
  const ProductDetailState({
    this.loaded = false,
    this.product,
    this.selection = const <String, String>{},
    this.quantity = 1,
    this.related = const <Product>[],
  });

  /// Whether the lookup has finished (the product may still be `null`).
  final bool loaded;

  /// The product, once loaded; `null` when the id is unknown.
  final Product? product;

  /// The chosen value of every variant group, keyed by group label.
  final Map<String, String> selection;

  /// How many to add.
  final int quantity;

  /// Other products worth a look.
  final List<Product> related;

  /// The cart's description of the chosen variant.
  String get variant => product?.variantLabel(selection) ?? '';

  /// The most that can be added at once.
  int get maxQuantity {
    final Product? p = product;
    if (p == null) return 1;
    return p.stock < maxLineQuantity ? p.stock : maxLineQuantity;
  }

  @override
  List<Object?> get props => <Object?>[
    loaded,
    product,
    selection,
    quantity,
    related,
  ];
}

/// State for the product page: the loaded product, the chosen variant and
/// quantity, and what else to suggest.
class ProductDetailCubit extends Cubit<ProductDetailState> {
  /// Creates the cubit.
  ProductDetailCubit(this._getProductById, this._getProducts, this._recommend)
    : super(const ProductDetailState());

  final GetProductById _getProductById;
  final GetProducts _getProducts;
  final RecommendProducts _recommend;

  /// Loads the product with its first variants selected.
  Future<void> load(String id) async {
    final Product? product = await _getProductById(id);
    final List<Product> all = await _getProducts();
    if (isClosed) return;
    if (product == null) {
      emit(const ProductDetailState(loaded: true));
      return;
    }
    emit(
      ProductDetailState(
        loaded: true,
        product: product,
        selection: product.defaultSelection,
        related: _recommend(
          all,
          exclude: <String>{product.id},
          category: product.category,
        ),
      ),
    );
  }

  /// Chooses [value] in the group called [label].
  void selectVariant(String label, String value) => emit(
    ProductDetailState(
      loaded: true,
      product: state.product,
      selection: <String, String>{...state.selection, label: value},
      quantity: state.quantity,
      related: state.related,
    ),
  );

  /// Sets how many to add, within what is in stock.
  void setQuantity(int quantity) {
    final int clamped = quantity.clamp(
      1,
      state.maxQuantity < 1 ? 1 : state.maxQuantity,
    );
    emit(
      ProductDetailState(
        loaded: true,
        product: state.product,
        selection: state.selection,
        quantity: clamped,
        related: state.related,
      ),
    );
  }
}
