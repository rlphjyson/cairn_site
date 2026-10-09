import '../../../common/utils/settings_failure.dart';
import '../../shared/models/action_result.dart';
import '../models/device_session.dart';
import '../repositories/security_repository.dart';

/// Signs other devices out.
class RevokeSession {
  /// Creates the use case.
  const RevokeSession(this._repository);

  final SecurityRepository _repository;

  /// Signs [session] out. Throws a [SettingsFailure] for the current device
  /// (use Sign out for that) or when the server refuses.
  Future<void> call(DeviceSession session) async {
    if (session.isCurrent) {
      throw const SettingsFailure(
        'This is the device you are using. Use Sign out instead.',
      );
    }
    _check(await _repository.revokeSession(session.id));
  }

  /// Signs out every device except the current one.
  Future<void> others() async =>
      _check(await _repository.revokeOtherSessions());

  void _check(ActionResult result) {
    if (!result.ok) {
      throw SettingsFailure(result.message ?? 'Could not sign out.');
    }
  }
}
