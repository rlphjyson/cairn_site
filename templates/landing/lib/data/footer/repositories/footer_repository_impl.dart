import '../../../domain/footer/mappers/footer_mapper.dart';
import '../../../domain/footer/models/footer_content.dart';
import '../../../domain/footer/repositories/footer_repository.dart';
import '../remote/footer_remote_data_source.dart';

/// Reads footer content from a remote data source and maps it.
class FooterRepositoryImpl implements FooterRepository {
  /// Creates the repository.
  const FooterRepositoryImpl(this._remote);

  final FooterRemoteDataSource _remote;

  @override
  Future<FooterContent> getFooter() async =>
      mapFooter(await _remote.fetchFooter());
}
