import '../models/download_content.dart';
import '../models/send_outcome.dart';

/// The get-the-app section: its copy, and sending the link.
abstract interface class DownloadRepository {
  /// The section copy.
  Future<DownloadContent> getDownload();

  /// Sends the download link to [contact].
  ///
  /// Throws a [DownloadLinkException] when the service refuses.
  Future<void> sendLink(Contact contact);
}
