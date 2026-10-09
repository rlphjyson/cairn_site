import '../../shared/models/action_result.dart';
import '../models/device_session.dart';

/// Everything that touches the account's security and lifetime.
abstract interface class SecurityRepository {
  /// Signed-in devices.
  Future<List<DeviceSession>> sessions();

  /// Signs [sessionId] out.
  Future<ActionResult> revokeSession(String sessionId);

  /// Signs out every device except the current one.
  Future<ActionResult> revokeOtherSessions();

  /// Changes the password.
  Future<ActionResult> changePassword({
    required String current,
    required String next,
  });

  /// Starts two-factor setup and returns the secret to enrol.
  Future<TwoFactorSetup> beginTwoFactor();

  /// Confirms setup with a [code] from the authenticator app.
  Future<ActionResult> verifyTwoFactor(String code);

  /// Turns two-factor off.
  Future<ActionResult> disableTwoFactor();

  /// Asks for a copy of the person's data.
  Future<DataExportRequest> requestExport();

  /// The people the person has blocked.
  Future<List<BlockedUser>> blockedUsers();

  /// Unblocks [userId].
  Future<ActionResult> unblock(String userId);

  /// Hides the account, keeping its data.
  Future<ActionResult> deactivateAccount();

  /// Permanently deletes the account.
  Future<ActionResult> deleteAccount();
}
