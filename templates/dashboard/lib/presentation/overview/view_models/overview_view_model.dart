import '../../../core/presentation/view_model.dart';
import '../bloc/overview_cubit.dart';

/// Owns the overview page's [OverviewCubit] for the life of the screen.
class OverviewViewModel implements ViewModel {
  /// Creates the view model.
  OverviewViewModel(this.cubit);

  /// The overview page state.
  final OverviewCubit cubit;

  @override
  void dispose() => cubit.close();
}
