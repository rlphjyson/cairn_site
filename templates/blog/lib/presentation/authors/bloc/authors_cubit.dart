import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/authors/models/author.dart';
import '../../../domain/authors/use_cases/get_author_profiles.dart';

/// What the About page is showing.
class AuthorsState extends Equatable {
  /// Creates a state.
  const AuthorsState({
    this.loading = true,
    this.failed = false,
    this.profiles = const <AuthorProfile>[],
  });

  /// Whether the authors are still loading.
  final bool loading;

  /// Whether loading failed.
  final bool failed;

  /// The authors, busiest first.
  final List<AuthorProfile> profiles;

  /// Posts across all authors.
  int get totalPosts =>
      profiles.fold(0, (int sum, AuthorProfile p) => sum + p.postCount);

  @override
  List<Object?> get props => <Object?>[loading, failed, profiles];
}

/// State for the About page. Scoped to one visit; its view model closes it.
class AuthorsCubit extends Cubit<AuthorsState> {
  /// Creates the cubit.
  AuthorsCubit(this._getProfiles) : super(const AuthorsState());

  final GetAuthorProfiles _getProfiles;

  /// Loads the authors.
  Future<void> load() async {
    emit(const AuthorsState());
    try {
      final List<AuthorProfile> profiles = await _getProfiles();
      if (isClosed) return;
      emit(AuthorsState(loading: false, profiles: profiles));
    } on Object {
      if (isClosed) return;
      emit(const AuthorsState(loading: false, failed: true));
    }
  }
}
