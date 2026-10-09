import '../../../domain/security/mappers/security_mapper.dart';
import '../../../domain/security/models/device_session.dart';
import '../../../domain/security/repositories/security_repository.dart';
import '../../../domain/shared/mappers/action_result_mapper.dart';
import '../../../domain/shared/models/action_result.dart';
import '../../settings/remote/settings_data_source.dart';

/// Security and account lifetime, through a [SettingsDataSource].
class SecurityRepositoryImpl implements SecurityRepository {
  /// Creates the repository.
  const SecurityRepositoryImpl(this._source);

  final SettingsDataSource _source;

  @override
  Future<List<DeviceSession>> sessions() async =>
      SecurityMapper.sessionsFromJson(await _source.loadSessions());

  @override
  Future<ActionResult> revokeSession(String sessionId) async =>
      ActionResultMapper.fromJson(await _source.revokeSession(sessionId));

  @override
  Future<ActionResult> revokeOtherSessions() async =>
      ActionResultMapper.fromJson(await _source.revokeOtherSessions());

  @override
  Future<ActionResult> changePassword({
    required String current,
    required String next,
  }) async => ActionResultMapper.fromJson(
    await _source.changePassword(current: current, next: next),
  );

  @override
  Future<TwoFactorSetup> beginTwoFactor() async =>
      SecurityMapper.twoFactorFromJson(await _source.beginTwoFactor());

  @override
  Future<ActionResult> verifyTwoFactor(String code) async =>
      ActionResultMapper.fromJson(await _source.verifyTwoFactor(code));

  @override
  Future<ActionResult> disableTwoFactor() async =>
      ActionResultMapper.fromJson(await _source.disableTwoFactor());

  @override
  Future<DataExportRequest> requestExport() async =>
      SecurityMapper.exportFromJson(await _source.requestExport());

  @override
  Future<List<BlockedUser>> blockedUsers() async =>
      SecurityMapper.blockedFromJson(await _source.loadBlockedUsers());

  @override
  Future<ActionResult> unblock(String userId) async =>
      ActionResultMapper.fromJson(await _source.unblockUser(userId));

  @override
  Future<ActionResult> deactivateAccount() async =>
      ActionResultMapper.fromJson(await _source.deactivateAccount());

  @override
  Future<ActionResult> deleteAccount() async =>
      ActionResultMapper.fromJson(await _source.deleteAccount());
}
