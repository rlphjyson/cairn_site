import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/catalog/models/product.dart';
import '../../../domain/saved/use_cases/get_saved_ids.dart';
import '../../../domain/saved/use_cases/get_saved_products.dart';
import '../../../domain/saved/use_cases/toggle_saved.dart';

/// The shopper's saved products.
class SavedState extends Equatable {
  /// Creates a state.
  const SavedState({
    this.ids = const <String>{},
    this.products = const <Product>[],
  });

  /// Saved product ids.
  final Set<String> ids;

  /// The same products, resolved, in catalogue order.
  final List<Product> products;

  /// Whether [id] is saved.
  bool isSaved(String id) => ids.contains(id);

  @override
  List<Object?> get props => <Object?>[ids, products];
}

/// Session-scoped state for saved products.
///
/// A lazy singleton: any screen reads it from context, and no view model owns
/// or closes it.
class SavedCubit extends Cubit<SavedState> {
  /// Creates the cubit.
  SavedCubit(this._getIds, this._toggle, this._getProducts)
    : super(const SavedState());

  final GetSavedIds _getIds;
  final ToggleSaved _toggle;
  final GetSavedProducts _getProducts;

  /// Loads the initial set.
  Future<void> load() async => _publish(await _getIds());

  /// Saves or un-saves [id].
  Future<void> toggle(String id) async => _publish(await _toggle(id));

  Future<void> _publish(Set<String> ids) async {
    final List<Product> products = await _getProducts(ids);
    if (isClosed) return;
    emit(SavedState(ids: ids, products: products));
  }
}
