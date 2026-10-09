import '../../../domain/docs/mappers/docs_mapper.dart';
import '../../../domain/docs/models/doc_version.dart';
import '../../../domain/docs/models/docs_site.dart';
import '../../../domain/docs/repositories/docs_repository.dart';
import '../remote/docs_remote_data_source.dart';

/// Reads documentation from a [DocsRemoteDataSource] and maps it.
///
/// Sites are cached per version: the sidebar, the search index and the pages
/// are all built from the same object, and flipping between versions should not
/// refetch.
class DocsRepositoryImpl implements DocsRepository {
  /// Creates the repository.
  DocsRepositoryImpl(this._remote, [this._mapper = const DocsMapper()]);

  final DocsRemoteDataSource _remote;
  final DocsMapper _mapper;
  final Map<String, DocsSite> _sites = <String, DocsSite>{};

  @override
  Future<List<DocVersion>> getVersions() async =>
      _mapper.versions(await _remote.fetchManifest());

  @override
  Future<DocsSite> getSite(String versionId) async {
    final DocsSite? cached = _sites[versionId];
    if (cached != null) return cached;
    final DocsSite site = _mapper.site(
      versionId,
      await _remote.fetchSite(versionId),
    );
    return _sites[versionId] = site;
  }
}
