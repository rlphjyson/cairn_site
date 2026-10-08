import '../../../core/presentation/view_model.dart';
import '../bloc/product_detail_cubit.dart';

/// Owns the product page's [ProductDetailCubit] for the lifetime of the screen.
class ProductDetailViewModel implements ViewModel {
  /// Creates the view model.
  ProductDetailViewModel(this.cubit);

  /// The product page state.
  final ProductDetailCubit cubit;

  @override
  void dispose() => cubit.close();
}
