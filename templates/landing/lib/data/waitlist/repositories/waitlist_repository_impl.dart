import '../../../domain/waitlist/mappers/waitlist_mapper.dart';
import '../../../domain/waitlist/models/join_outcome.dart';
import '../../../domain/waitlist/models/waitlist_content.dart';
import '../../../domain/waitlist/repositories/waitlist_repository.dart';
import '../remote/waitlist_remote_data_source.dart';

/// Reads the waitlist copy and submits signups through a data source.
class WaitlistRepositoryImpl implements WaitlistRepository {
  /// Creates the repository.
  const WaitlistRepositoryImpl(this._remote);

  final WaitlistRemoteDataSource _remote;

  @override
  Future<WaitlistContent> getWaitlist() async =>
      mapWaitlist(await _remote.fetchWaitlist());

  @override
  Future<WaitlistReceipt> join(String email) async =>
      mapReceipt(await _remote.submit(email));
}
