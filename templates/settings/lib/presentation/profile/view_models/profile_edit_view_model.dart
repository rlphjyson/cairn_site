import '../../../core/presentation/view_model.dart';
import '../bloc/profile_edit_cubit.dart';

/// Owns the Edit profile screen's [ProfileEditCubit].
class ProfileEditViewModel implements ViewModel {
  /// Creates the view model.
  ProfileEditViewModel(this.cubit);

  /// The draft.
  final ProfileEditCubit cubit;

  @override
  void dispose() => cubit.close();
}
