import '../models/waitlist_content.dart';
import '../repositories/waitlist_repository.dart';

/// Loads the waitlist section copy.
class GetWaitlist {
  /// Creates the use case.
  const GetWaitlist(this._repository);

  final WaitlistRepository _repository;

  /// Runs the use case.
  Future<WaitlistContent> call() => _repository.getWaitlist();
}
