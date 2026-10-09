import '../models/doc_version.dart';
import '../models/docs_site.dart';

/// Where documentation comes from.
abstract interface class DocsRepository {
  /// Every published version; exactly one should be the latest.
  Future<List<DocVersion>> getVersions();

  /// The sidebar tree and pages of [versionId].
  Future<DocsSite> getSite(String versionId);
}
