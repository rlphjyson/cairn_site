import '../../../core/presentation/view_model.dart';
import '../bloc/sign_up_cubit.dart';

/// Owns a [SignUpCubit] for the lifetime of the screen showing it.
class SignUpViewModel implements ViewModel {
  /// Creates the view model.
  SignUpViewModel(this.cubit);

  /// The sign-up form's state.
  final SignUpCubit cubit;

  @override
  void dispose() => cubit.close();
}
