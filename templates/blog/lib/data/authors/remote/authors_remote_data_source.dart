import '../../posts/remote/blog_seed.dart';

/// Where the blog's authors come from.
///
/// Implement this against your CMS or API and register it in
/// `core/infrastructure/di/blog_injection.dart` in place of
/// [InMemoryAuthorsRemoteDataSource]. Each author is a JSON object:
/// `id`, `name`, `role`, `bio`, `avatar` (an asset path or URL).
abstract interface class AuthorsRemoteDataSource {
  /// Every author as decoded JSON.
  Future<List<Map<String, Object?>>> fetchAuthors();
}

/// Serves the seed authors from memory. Replace it with a real source.
class InMemoryAuthorsRemoteDataSource implements AuthorsRemoteDataSource {
  /// Creates the source.
  const InMemoryAuthorsRemoteDataSource();

  @override
  Future<List<Map<String, Object?>>> fetchAuthors() async => seedAuthors;
}
