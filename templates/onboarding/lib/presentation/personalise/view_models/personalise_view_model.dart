import '../../../core/presentation/view_model.dart';
import '../bloc/personalise_cubit.dart';

/// Owns the personalise step's [PersonaliseCubit] for the lifetime of the
/// screen.
class PersonaliseViewModel implements ViewModel {
  /// Creates the view model.
  PersonaliseViewModel(this.cubit);

  /// The draft answers.
  final PersonaliseCubit cubit;

  @override
  void dispose() => cubit.close();
}
