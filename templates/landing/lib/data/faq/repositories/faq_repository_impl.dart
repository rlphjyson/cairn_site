import '../../../domain/faq/mappers/faq_mapper.dart';
import '../../../domain/faq/models/faq_content.dart';
import '../../../domain/faq/repositories/faq_repository.dart';
import '../remote/faq_remote_data_source.dart';

/// Reads faq content from a remote data source and maps it.
class FaqRepositoryImpl implements FaqRepository {
  /// Creates the repository.
  const FaqRepositoryImpl(this._remote);

  final FaqRemoteDataSource _remote;

  @override
  Future<FaqContent> getFaq() async => mapFaq(await _remote.fetchFaq());
}
