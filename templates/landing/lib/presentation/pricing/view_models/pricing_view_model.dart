import '../../../core/presentation/view_model.dart';
import '../bloc/pricing_cubit.dart';

/// Owns the [PricingCubit] for the life of the pricing section.
class PricingViewModel implements ViewModel {
  /// Creates the view model.
  PricingViewModel(this.cubit);

  /// The pricing state.
  final PricingCubit cubit;

  @override
  void dispose() => cubit.close();
}
