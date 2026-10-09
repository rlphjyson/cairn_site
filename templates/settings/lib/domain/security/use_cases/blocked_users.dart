import '../../../common/utils/settings_failure.dart';
import '../models/device_session.dart';
import '../repositories/security_repository.dart';

/// Lists the people the person has blocked.
class GetBlockedUsers {
  /// Creates the use case.
  const GetBlockedUsers(this._repository);

  final SecurityRepository _repository;

  /// The blocked users.
  Future<List<BlockedUser>> call() => _repository.blockedUsers();
}

/// Unblocks someone.
class UnblockUser {
  /// Creates the use case.
  const UnblockUser(this._repository);

  final SecurityRepository _repository;

  /// Throws a [SettingsFailure] when the server refuses.
  Future<void> call(String userId) async {
    final result = await _repository.unblock(userId);
    if (!result.ok) {
      throw SettingsFailure(result.message ?? 'Could not unblock them.');
    }
  }
}
