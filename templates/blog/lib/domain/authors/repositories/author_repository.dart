import '../models/author.dart';

/// Where authors come from.
abstract interface class AuthorRepository {
  /// Every author.
  Future<List<Author>> getAuthors();
}
