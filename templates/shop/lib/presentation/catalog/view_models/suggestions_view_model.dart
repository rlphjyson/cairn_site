import '../../../core/presentation/view_model.dart';
import '../bloc/suggestions_cubit.dart';

/// Owns a [SuggestionsCubit] for the lifetime of the widget showing it.
class SuggestionsViewModel implements ViewModel {
  /// Creates the view model.
  SuggestionsViewModel(this.cubit);

  /// The suggestions state.
  final SuggestionsCubit cubit;

  @override
  void dispose() => cubit.close();
}
