import '../models/download_content.dart';
import '../repositories/download_repository.dart';

/// Loads the get-the-app section copy.
class GetDownload {
  /// Creates the use case.
  const GetDownload(this._repository);

  final DownloadRepository _repository;

  /// Runs the use case.
  Future<DownloadContent> call() => _repository.getDownload();
}
