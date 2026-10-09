import '../../../core/presentation/view_model.dart';
import '../bloc/verify_code_cubit.dart';

/// Owns a [VerifyCodeCubit] for the lifetime of the screen showing it.
class VerifyCodeViewModel implements ViewModel {
  /// Creates the view model.
  VerifyCodeViewModel(this.cubit);

  /// The verification state.
  final VerifyCodeCubit cubit;

  @override
  void dispose() => cubit.close();
}
