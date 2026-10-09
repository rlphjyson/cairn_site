import '../../../core/presentation/view_model.dart';
import '../bloc/support_cubit.dart';

/// Owns the Help screen's [SupportCubit].
class SupportViewModel implements ViewModel {
  /// Creates the view model.
  SupportViewModel(this.cubit);

  /// The contact form's cubit.
  final SupportCubit cubit;

  @override
  void dispose() => cubit.close();
}
