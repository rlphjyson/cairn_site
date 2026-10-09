import '../models/post.dart';

/// Where posts come from.
abstract interface class PostRepository {
  /// Every published post, in no particular order.
  Future<List<Post>> getPosts();

  /// One post, or `null` if there is no such id.
  Future<Post?> getPost(String id);
}
