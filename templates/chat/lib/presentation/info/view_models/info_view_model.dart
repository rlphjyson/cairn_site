import '../../../core/presentation/view_model.dart';
import '../bloc/info_cubit.dart';

/// Owns the [InfoCubit] of one visit to the information screen.
class InfoViewModel implements ViewModel {
  /// Creates the view model.
  InfoViewModel(this.cubit);

  /// The screen's state.
  final InfoCubit cubit;

  @override
  void dispose() => cubit.close();
}
