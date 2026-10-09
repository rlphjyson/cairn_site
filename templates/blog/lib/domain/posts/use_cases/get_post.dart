import '../models/post.dart';
import '../repositories/post_repository.dart';

/// Loads one post by id, or `null` if it does not exist.
class GetPost {
  /// Creates the use case.
  const GetPost(this._posts);

  final PostRepository _posts;

  /// Runs it.
  Future<Post?> call(String id) => _posts.getPost(id);
}
