import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A place in the blog.
sealed class BlogRoute extends Equatable {
  const BlogRoute();
}

/// The post list.
class HomeRoute extends BlogRoute {
  /// Creates the route.
  const HomeRoute();

  @override
  List<Object?> get props => const <Object?>[];
}

/// One article.
class PostRoute extends BlogRoute {
  /// Creates the route.
  const PostRoute(this.id);

  /// The post's id.
  final String id;

  @override
  List<Object?> get props => <Object?>[id];
}

/// The About page.
class AboutRoute extends BlogRoute {
  /// Creates the route.
  const AboutRoute();

  @override
  List<Object?> get props => const <Object?>[];
}

/// Which page is showing, with a small back stack.
///
/// The template keeps its own navigation so it runs inside any host app. In a
/// real project, swap this cubit for `go_router` and keep every view; the
/// docs show how.
class BlogNavigationCubit extends Cubit<BlogRoute> {
  /// Creates the cubit, showing the home page.
  BlogNavigationCubit() : super(const HomeRoute());

  final List<BlogRoute> _history = <BlogRoute>[];

  /// Shows the post list and forgets where you came from.
  void openHome() {
    _history.clear();
    emit(const HomeRoute());
  }

  /// Shows the post [id], remembering the current page for [back].
  void openPost(String id) => _push(PostRoute(id));

  /// Shows the About page, remembering the current page for [back].
  void openAbout() => _push(const AboutRoute());

  /// Returns to the previous page, or the home page if there is none.
  void back() {
    if (_history.isEmpty) {
      emit(const HomeRoute());
    } else {
      emit(_history.removeLast());
    }
  }

  void _push(BlogRoute next) {
    if (next == state) return;
    _history.add(state);
    emit(next);
  }
}
