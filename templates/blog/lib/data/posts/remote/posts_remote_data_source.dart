import 'blog_seed.dart';

/// Where the blog's posts come from.
///
/// This is the one place to connect a CMS, a REST API or Firebase: implement
/// it, then register your class in `core/infrastructure/di/blog_injection.dart`
/// in place of [InMemoryPostsRemoteDataSource], or pass it to
/// `BlogApp(postsDataSource: ...)`.
///
/// Each post is a JSON object; see `blog_seed.dart` for the full shape and
/// `PostMapper` for what is required.
abstract interface class PostsRemoteDataSource {
  /// Every post as decoded JSON.
  Future<List<Map<String, Object?>>> fetchPosts();
}

/// Serves the seed posts from memory. Replace it with a real source.
class InMemoryPostsRemoteDataSource implements PostsRemoteDataSource {
  /// Creates the source.
  const InMemoryPostsRemoteDataSource();

  @override
  Future<List<Map<String, Object?>>> fetchPosts() async => seedPosts;
}
