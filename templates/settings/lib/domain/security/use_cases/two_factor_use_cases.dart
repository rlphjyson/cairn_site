import '../../../common/utils/settings_failure.dart';
import '../models/device_session.dart';
import '../repositories/security_repository.dart';

/// Starts two-factor setup.
class BeginTwoFactor {
  /// Creates the use case.
  const BeginTwoFactor(this._repository);

  final SecurityRepository _repository;

  /// The secret to enrol in an authenticator app.
  Future<TwoFactorSetup> call() => _repository.beginTwoFactor();
}

/// Confirms two-factor setup with a code.
class VerifyTwoFactor {
  /// Creates the use case.
  const VerifyTwoFactor(this._repository);

  final SecurityRepository _repository;

  /// Whether [code] looks like a code: exactly six digits.
  static bool isWellFormed(String code) => RegExp(r'^\d{6}$').hasMatch(code);

  /// Throws a [SettingsFailure] when [code] is malformed or wrong.
  Future<void> call(String code) async {
    if (!isWellFormed(code)) {
      throw const SettingsFailure('Enter the 6-digit code.');
    }
    final result = await _repository.verifyTwoFactor(code);
    if (!result.ok) {
      throw SettingsFailure(
        result.message ?? 'That code is not right. Try the next one.',
      );
    }
  }
}

/// Turns two-factor off.
class DisableTwoFactor {
  /// Creates the use case.
  const DisableTwoFactor(this._repository);

  final SecurityRepository _repository;

  /// Throws a [SettingsFailure] when the server refuses.
  Future<void> call() async {
    final result = await _repository.disableTwoFactor();
    if (!result.ok) {
      throw SettingsFailure(result.message ?? 'Could not turn it off.');
    }
  }
}
