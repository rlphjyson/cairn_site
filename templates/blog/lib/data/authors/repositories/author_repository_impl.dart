import '../../../domain/authors/mappers/author_mapper.dart';
import '../../../domain/authors/models/author.dart';
import '../../../domain/authors/repositories/author_repository.dart';
import '../remote/authors_remote_data_source.dart';

/// [AuthorRepository] over a remote data source.
class AuthorRepositoryImpl implements AuthorRepository {
  /// Creates the repository.
  const AuthorRepositoryImpl(this._remote);

  final AuthorsRemoteDataSource _remote;

  @override
  Future<List<Author>> getAuthors() async => <Author>[
    for (final Map<String, Object?> json in await _remote.fetchAuthors())
      AuthorMapper.fromJson(json),
  ];
}
