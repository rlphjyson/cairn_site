import '../../../common/constants/blog_config.dart';
import '../models/post.dart';
import '../repositories/post_repository.dart';

/// The posts most like a given one.
///
/// A post scores 3 for the same category, 2 per shared tag and 1 for the same
/// author; ties go to the newer post. Posts that score nothing are never
/// returned, so the row can be shorter than [limit] or empty.
class GetRelatedPosts {
  /// Creates the use case.
  const GetRelatedPosts(this._posts);

  final PostRepository _posts;

  /// Runs it.
  Future<List<Post>> call(
    Post post, {
    int limit = BlogConfig.relatedCount,
  }) async => rank(post, await _posts.getPosts(), limit: limit);

  /// The ranking on its own, for callers that already hold the list.
  List<Post> rank(
    Post post,
    List<Post> all, {
    int limit = BlogConfig.relatedCount,
  }) {
    int score(Post other) {
      int s = 0;
      if (other.category == post.category) s += 3;
      s += 2 * other.tags.where(post.tags.contains).length;
      if (other.author.id == post.author.id) s += 1;
      return s;
    }

    final List<Post> candidates = <Post>[
      for (final Post p in all)
        if (p.id != post.id && score(p) > 0) p,
    ];
    candidates.sort((Post a, Post b) {
      final int byScore = score(b).compareTo(score(a));
      if (byScore != 0) return byScore;
      final int byDate = b.publishedAt.compareTo(a.publishedAt);
      return byDate != 0 ? byDate : a.id.compareTo(b.id);
    });
    return candidates.take(limit).toList();
  }
}
