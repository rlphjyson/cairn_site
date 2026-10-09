import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/docs/models/docs_site.dart';
import '../../../domain/search/models/search_hit.dart';
import '../../../domain/search/use_cases/search_docs.dart';

/// The search index for the open version.
class SearchState extends Equatable {
  /// Creates a state.
  const SearchState({this.hits = const <SearchHit>[]});

  /// Every searchable page and heading, in the order the palette lists them.
  final List<SearchHit> hits;

  @override
  List<Object?> get props => <Object?>[hits];
}

/// Session cubit holding the palette's index. `DocsProviders` rebuilds it
/// whenever a new version finishes loading.
class SearchCubit extends Cubit<SearchState> {
  /// Creates the cubit.
  SearchCubit(this._search) : super(const SearchState());

  final SearchDocs _search;

  /// Indexes [site].
  void index(DocsSite site) => emit(SearchState(hits: _search(site)));

  /// Ranked results for [query] over the current index (empty query: all).
  List<SearchHit> search(DocsSite site, String query) =>
      _search(site, query: query);
}
