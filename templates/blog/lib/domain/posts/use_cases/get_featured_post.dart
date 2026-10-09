import '../models/post.dart';

/// Picks the post for the home page's hero.
///
/// The newest post flagged `featured`, or the newest post if none is.
/// [posts] must already be sorted newest first (see `GetPosts`).
class GetFeaturedPost {
  /// Creates the use case.
  const GetFeaturedPost();

  /// Runs it. `null` when there are no posts.
  Post? call(List<Post> posts) {
    if (posts.isEmpty) return null;
    for (final Post p in posts) {
      if (p.featured) return p;
    }
    return posts.first;
  }
}
