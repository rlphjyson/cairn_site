import 'package:equatable/equatable.dart';

import '../../../core/presentation/safe_cubit.dart';

import '../../../domain/settings/use_cases/search_settings.dart';

/// What the search field holds and what it found.
class SearchState extends Equatable {
  /// Creates a state.
  const SearchState({
    this.query = '',
    this.groups = const <SettingsSearchGroup>[],
  });

  /// The text in the field.
  final String query;

  /// The matches, grouped by section.
  final List<SettingsSearchGroup> groups;

  /// Whether the person is searching, as opposed to browsing.
  bool get isSearching => query.trim().isNotEmpty;

  /// Whether a search found nothing.
  bool get isEmpty => isSearching && groups.isEmpty;

  /// How many settings matched.
  int get count =>
      groups.fold(0, (int sum, SettingsSearchGroup g) => sum + g.hits.length);

  @override
  List<Object?> get props => <Object?>[query, groups];
}

/// The settings search. Screen-scoped, owned by the home screen.
class SearchCubit extends SafeCubit<SearchState> {
  /// Creates the cubit.
  SearchCubit(this._search) : super(const SearchState());

  final SearchSettings _search;

  /// Searches for [query]. An empty query clears the results.
  void setQuery(String query) =>
      emit(SearchState(query: query, groups: _search(query)));

  /// Clears the field.
  void clear() => emit(const SearchState());
}
