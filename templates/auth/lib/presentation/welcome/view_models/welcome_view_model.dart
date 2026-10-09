import '../../../core/presentation/view_model.dart';
import '../bloc/welcome_cubit.dart';

/// Owns a [WelcomeCubit] for the lifetime of the screen showing it.
class WelcomeViewModel implements ViewModel {
  /// Creates the view model.
  WelcomeViewModel(this.cubit);

  /// The welcome screen's social sign-in state.
  final WelcomeCubit cubit;

  @override
  void dispose() => cubit.close();
}
