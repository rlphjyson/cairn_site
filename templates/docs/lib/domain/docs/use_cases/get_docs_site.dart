import '../models/docs_site.dart';
import '../repositories/docs_repository.dart';

/// Loads the content of one version.
class GetDocsSite {
  /// Creates the use case.
  const GetDocsSite(this._repository);

  final DocsRepository _repository;

  /// Runs it.
  Future<DocsSite> call(String versionId) => _repository.getSite(versionId);
}
