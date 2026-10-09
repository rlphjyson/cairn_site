import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/posts/models/post.dart';
import '../../../domain/posts/use_cases/get_post.dart';
import '../../../domain/posts/use_cases/get_related_posts.dart';

/// Where the article is in loading.
enum PostDetailStatus {
  /// Waiting for the data source.
  loading,

  /// The post and its related posts are available.
  ready,

  /// There is no post with that id.
  notFound,

  /// The data source failed.
  failure,
}

/// What the article page is showing.
class PostDetailState extends Equatable {
  /// Creates a state.
  const PostDetailState({
    this.status = PostDetailStatus.loading,
    this.post,
    this.related = const <Post>[],
  });

  /// Where loading stands.
  final PostDetailStatus status;

  /// The article.
  final Post? post;

  /// Posts like it.
  final List<Post> related;

  @override
  List<Object?> get props => <Object?>[status, post, related];
}

/// State for one article. Scoped to one visit; its view model closes it.
class PostDetailCubit extends Cubit<PostDetailState> {
  /// Creates the cubit.
  PostDetailCubit(this._getPost, this._getRelated)
    : super(const PostDetailState());

  final GetPost _getPost;
  final GetRelatedPosts _getRelated;

  /// Loads the post [id] and the posts related to it.
  Future<void> load(String id) async {
    emit(const PostDetailState());
    try {
      final Post? post = await _getPost(id);
      if (isClosed) return;
      if (post == null) {
        emit(const PostDetailState(status: PostDetailStatus.notFound));
        return;
      }
      final List<Post> related = await _getRelated(post);
      if (isClosed) return;
      emit(
        PostDetailState(
          status: PostDetailStatus.ready,
          post: post,
          related: related,
        ),
      );
    } on Object {
      if (isClosed) return;
      emit(const PostDetailState(status: PostDetailStatus.failure));
    }
  }
}
