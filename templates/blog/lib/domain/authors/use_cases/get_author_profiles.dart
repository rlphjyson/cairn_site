import '../../posts/models/post.dart';
import '../../posts/repositories/post_repository.dart';
import '../models/author.dart';
import '../repositories/author_repository.dart';

/// Loads every author with their number of posts, busiest first.
class GetAuthorProfiles {
  /// Creates the use case.
  const GetAuthorProfiles(this._authors, this._posts);

  final AuthorRepository _authors;
  final PostRepository _posts;

  /// Runs it.
  Future<List<AuthorProfile>> call() async {
    final List<Author> authors = await _authors.getAuthors();
    final List<Post> posts = await _posts.getPosts();
    final List<AuthorProfile> profiles = <AuthorProfile>[
      for (final Author a in authors)
        AuthorProfile(
          author: a,
          postCount: posts.where((Post p) => p.author.id == a.id).length,
        ),
    ];
    // List.sort is not guaranteed stable: ties keep the source order by index.
    final List<int> order = List<int>.generate(profiles.length, (int i) => i)
      ..sort((int a, int b) {
        final int byCount = profiles[b].postCount.compareTo(
          profiles[a].postCount,
        );
        return byCount != 0 ? byCount : a.compareTo(b);
      });
    return <AuthorProfile>[for (final int i in order) profiles[i]];
  }
}
