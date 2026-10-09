import '../../../core/presentation/view_model.dart';
import '../bloc/reset_password_cubit.dart';

/// Owns a [ResetPasswordCubit] for the lifetime of the screen showing it.
class ResetPasswordViewModel implements ViewModel {
  /// Creates the view model.
  ResetPasswordViewModel(this.cubit);

  /// The reset form's state.
  final ResetPasswordCubit cubit;

  @override
  void dispose() => cubit.close();
}
