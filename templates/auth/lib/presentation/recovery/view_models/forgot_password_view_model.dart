import '../../../core/presentation/view_model.dart';
import '../bloc/forgot_password_cubit.dart';

/// Owns a [ForgotPasswordCubit] for the lifetime of the screen showing it.
class ForgotPasswordViewModel implements ViewModel {
  /// Creates the view model.
  ForgotPasswordViewModel(this.cubit);

  /// The forgot-password form's state.
  final ForgotPasswordCubit cubit;

  @override
  void dispose() => cubit.close();
}
