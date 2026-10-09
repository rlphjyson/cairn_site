import '../../../common/constants/content_sections.dart';
import '../../../domain/download/mappers/download_mapper.dart';
import '../../../domain/download/models/download_content.dart';
import '../../../domain/download/models/send_outcome.dart';
import '../../../domain/download/repositories/download_repository.dart';
import '../../content/remote/app_content_data_source.dart';
import '../remote/download_link_service.dart';

/// Reads the section copy from the content data source and sends links
/// through the [DownloadLinkService].
class DownloadRepositoryImpl implements DownloadRepository {
  /// Creates the repository.
  const DownloadRepositoryImpl(this._content, this._links);

  final AppContentDataSource _content;
  final DownloadLinkService _links;

  @override
  Future<DownloadContent> getDownload() async =>
      mapDownload(await _content.fetchSection(ContentSections.download));

  @override
  Future<void> sendLink(Contact contact) => _links.send(contact);
}
