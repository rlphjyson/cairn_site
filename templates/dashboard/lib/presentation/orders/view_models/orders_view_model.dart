import '../../../core/presentation/view_model.dart';
import '../bloc/orders_cubit.dart';

/// Owns the orders page's [OrdersCubit] for the life of the screen.
class OrdersViewModel implements ViewModel {
  /// Creates the view model.
  OrdersViewModel(this.cubit);

  /// The orders page state.
  final OrdersCubit cubit;

  @override
  void dispose() => cubit.close();
}
