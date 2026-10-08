import '../../../core/presentation/view_model.dart';
import '../bloc/catalog_cubit.dart';

/// Owns the storefront's [CatalogCubit] for the lifetime of the screen.
class StorefrontViewModel implements ViewModel {
  /// Creates the view model.
  StorefrontViewModel(this.cubit);

  /// The storefront state.
  final CatalogCubit cubit;

  @override
  void dispose() => cubit.close();
}
