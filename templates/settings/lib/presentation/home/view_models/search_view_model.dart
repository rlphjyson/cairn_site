import '../../../core/presentation/view_model.dart';
import '../bloc/search_cubit.dart';

/// Owns the home screen's [SearchCubit].
class SearchViewModel implements ViewModel {
  /// Creates the view model.
  SearchViewModel(this.cubit);

  /// The search.
  final SearchCubit cubit;

  @override
  void dispose() => cubit.close();
}
