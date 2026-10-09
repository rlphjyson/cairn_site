import '../../../core/presentation/view_model.dart';
import '../bloc/authors_cubit.dart';

/// Owns the About page's [AuthorsCubit] for the life of the screen.
class AuthorsViewModel implements ViewModel {
  /// Creates the view model.
  AuthorsViewModel(this.cubit);

  /// The authors state.
  final AuthorsCubit cubit;

  @override
  void dispose() => cubit.close();
}
