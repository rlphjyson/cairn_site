import '../../../domain/newsletter/mappers/subscribe_result_mapper.dart';
import '../../../domain/newsletter/models/subscribe_result.dart';
import '../../../domain/newsletter/repositories/newsletter_repository.dart';
import '../remote/newsletter_remote_data_source.dart';

/// [NewsletterRepository] over a remote data source.
class NewsletterRepositoryImpl implements NewsletterRepository {
  /// Creates the repository.
  const NewsletterRepositoryImpl(this._remote);

  final NewsletterRemoteDataSource _remote;

  @override
  Future<SubscribeResult> subscribe(String email) async {
    try {
      return SubscribeResultMapper.fromJson(await _remote.subscribe(email));
    } on NewsletterException {
      rethrow;
    } on Object {
      throw const NewsletterException(
        'Something went wrong. Check your connection and try again.',
      );
    }
  }
}
