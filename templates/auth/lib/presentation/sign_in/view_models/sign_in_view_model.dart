import '../../../core/presentation/view_model.dart';
import '../bloc/sign_in_cubit.dart';

/// Owns a [SignInCubit] for the lifetime of the screen showing it.
class SignInViewModel implements ViewModel {
  /// Creates the view model.
  SignInViewModel(this.cubit);

  /// The sign-in form's state.
  final SignInCubit cubit;

  @override
  void dispose() => cubit.close();
}
