import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/catalog/models/product.dart';
import '../../../domain/catalog/use_cases/get_products.dart';
import '../../../domain/catalog/use_cases/recommend_products.dart';

/// Products to suggest on screens that have nothing else to show.
class SuggestionsCubit extends Cubit<List<Product>> {
  /// Creates the cubit.
  SuggestionsCubit(this._getProducts, this._recommend)
    : super(const <Product>[]);

  final GetProducts _getProducts;
  final RecommendProducts _recommend;

  /// Loads the best-rated products, leaving out [exclude].
  Future<void> load({Set<String> exclude = const <String>{}}) async {
    final List<Product> all = await _getProducts();
    if (isClosed) return;
    emit(_recommend(all, exclude: exclude, limit: 4));
  }
}
