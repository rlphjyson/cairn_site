import '../../../core/presentation/view_model.dart';
import '../bloc/waitlist_cubit.dart';

/// Owns the [WaitlistCubit] for the life of the waitlist section.
class WaitlistViewModel implements ViewModel {
  /// Creates the view model.
  WaitlistViewModel(this.cubit);

  /// The form state.
  final WaitlistCubit cubit;

  @override
  void dispose() => cubit.close();
}
