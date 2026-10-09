import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/constants/blog_config.dart';
import '../../../domain/posts/models/post.dart';
import '../../../domain/posts/models/post_page.dart';
import '../../../domain/posts/models/post_query.dart';
import '../../../domain/posts/use_cases/get_categories.dart';
import '../../../domain/posts/use_cases/get_featured_post.dart';
import '../../../domain/posts/use_cases/get_posts.dart';
import '../../../domain/posts/use_cases/query_posts.dart';

/// Whether the feed has its posts.
enum FeedStatus {
  /// Nothing requested yet.
  initial,

  /// Waiting for the data source.
  loading,

  /// Posts are available (there may still be none that match).
  ready,

  /// The data source failed.
  failure,
}

/// What the home page is showing.
class PostsFeedState extends Equatable {
  /// Creates a state.
  const PostsFeedState({
    this.status = FeedStatus.initial,
    this.posts = const <Post>[],
    this.categories = const <String>[],
    this.featured,
    this.query = const PostQuery(pageSize: BlogConfig.pageSize),
    this.page = PostPage.empty,
  });

  /// Where loading stands.
  final FeedStatus status;

  /// Every post, newest first.
  final List<Post> posts;

  /// The category chips.
  final List<String> categories;

  /// The hero post, if any.
  final Post? featured;

  /// The active category, search and page.
  final PostQuery query;

  /// The posts to show in the grid.
  final PostPage page;

  /// Whether the hero is visible: only on the unfiltered first page.
  bool get showFeatured =>
      status == FeedStatus.ready &&
      featured != null &&
      !query.isFiltered &&
      page.page == 1;

  @override
  List<Object?> get props => <Object?>[
    status,
    posts,
    categories,
    featured,
    query,
    page,
  ];
}

/// The home page's posts, filters and page. A session cubit: it survives
/// opening a post, so "back" returns to the same search and page.
class PostsFeedCubit extends Cubit<PostsFeedState> {
  /// Creates the cubit.
  PostsFeedCubit(
    this._getPosts,
    this._getCategories,
    this._getFeatured,
    this._queryPosts,
  ) : super(const PostsFeedState());

  final GetPosts _getPosts;
  final GetCategories _getCategories;
  final GetFeaturedPost _getFeatured;
  final QueryPosts _queryPosts;

  /// Loads the posts once; later calls do nothing unless the last one failed.
  Future<void> ensureLoaded() async {
    if (state.status == FeedStatus.initial ||
        state.status == FeedStatus.failure) {
      await load();
    }
  }

  /// Loads (or reloads) the posts.
  Future<void> load() async {
    emit(PostsFeedState(status: FeedStatus.loading, query: state.query));
    try {
      final List<Post> posts = await _getPosts();
      if (isClosed) return;
      emit(_ready(posts, state.query));
    } on Object {
      if (isClosed) return;
      emit(PostsFeedState(status: FeedStatus.failure, query: state.query));
    }
  }

  /// Shows one category, or all when [category] is `null`. Goes back to page 1.
  void selectCategory(String? category) => _requery(
    category == null
        ? state.query.copyWith(clearCategory: true, page: 1)
        : state.query.copyWith(category: category, page: 1),
  );

  /// Searches for [text]. Goes back to page 1.
  void search(String text) =>
      _requery(state.query.copyWith(search: text, page: 1));

  /// Shows [page] (1-based).
  void goToPage(int page) => _requery(state.query.copyWith(page: page));

  /// Removes the category and the search.
  void clearFilters() =>
      _requery(state.query.copyWith(clearCategory: true, search: '', page: 1));

  void _requery(PostQuery query) {
    if (state.status != FeedStatus.ready) {
      // Remember the query; it is applied when the posts arrive.
      emit(
        PostsFeedState(status: state.status, posts: state.posts, query: query),
      );
      return;
    }
    emit(_ready(state.posts, query));
  }

  PostsFeedState _ready(List<Post> posts, PostQuery query) {
    final Post? featured = _getFeatured(posts);
    return PostsFeedState(
      status: FeedStatus.ready,
      posts: posts,
      categories: _getCategories(posts),
      featured: featured,
      query: query,
      // The hero already shows the featured post, so the unfiltered grid
      // leaves it out.
      page: _queryPosts(
        posts,
        query,
        excludeId: query.isFiltered ? null : featured?.id,
      ),
    );
  }
}
