import '../models/doc_version.dart';
import '../repositories/docs_repository.dart';

/// Lists the published versions.
class GetVersions {
  /// Creates the use case.
  const GetVersions(this._repository);

  final DocsRepository _repository;

  /// Runs it.
  Future<List<DocVersion>> call() => _repository.getVersions();
}
