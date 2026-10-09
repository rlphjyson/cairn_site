import '../models/post.dart';
import '../repositories/post_repository.dart';

/// Loads every post, newest first.
class GetPosts {
  /// Creates the use case.
  const GetPosts(this._posts);

  final PostRepository _posts;

  /// Runs it.
  Future<List<Post>> call() async {
    final List<Post> posts = List<Post>.of(await _posts.getPosts());
    final Map<Post, int> position = <Post, int>{
      for (int i = 0; i < posts.length; i++) posts[i]: i,
    };
    posts.sort((Post a, Post b) {
      final int byDate = b.publishedAt.compareTo(a.publishedAt);
      return byDate != 0 ? byDate : position[a]!.compareTo(position[b]!);
    });
    return posts;
  }
}
