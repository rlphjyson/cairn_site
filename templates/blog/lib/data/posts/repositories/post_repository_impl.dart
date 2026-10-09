import '../../../domain/authors/models/author.dart';
import '../../../domain/authors/repositories/author_repository.dart';
import '../../../domain/posts/mappers/post_mapper.dart';
import '../../../domain/posts/models/post.dart';
import '../../../domain/posts/repositories/post_repository.dart';
import '../remote/posts_remote_data_source.dart';

/// [PostRepository] over a remote data source.
///
/// A post names its author by id, so this resolves them through the authors'
/// domain interface (never their data layer).
class PostRepositoryImpl implements PostRepository {
  /// Creates the repository.
  const PostRepositoryImpl(this._remote, this._authors);

  final PostsRemoteDataSource _remote;
  final AuthorRepository _authors;

  @override
  Future<List<Post>> getPosts() async {
    final Map<String, Author> authors = <String, Author>{
      for (final Author a in await _authors.getAuthors()) a.id: a,
    };
    return <Post>[
      for (final Map<String, Object?> json in await _remote.fetchPosts())
        PostMapper.fromJson(json, authors),
    ];
  }

  @override
  Future<Post?> getPost(String id) async {
    for (final Post post in await getPosts()) {
      if (post.id == id) return post;
    }
    return null;
  }
}
