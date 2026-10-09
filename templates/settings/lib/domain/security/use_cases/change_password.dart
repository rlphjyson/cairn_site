import '../../../common/utils/settings_failure.dart';
import '../models/password_strength.dart';
import '../models/password_validation.dart';
import '../repositories/security_repository.dart';

/// Validates and changes the password.
class ChangePassword {
  /// Creates the use case.
  const ChangePassword(this._repository);

  final SecurityRepository _repository;

  /// Checks the three fields. Pure.
  PasswordValidation validate({
    required String current,
    required String next,
    required String confirm,
  }) {
    final Map<PasswordField, String> errors = <PasswordField, String>{};
    if (current.isEmpty) {
      errors[PasswordField.current] = 'Enter your current password.';
    }
    if (next.length < PasswordStrength.minLength) {
      errors[PasswordField.next] =
          'Use at least ${PasswordStrength.minLength} characters.';
    } else if (next == current) {
      errors[PasswordField.next] = 'Choose a password you are not using now.';
    } else if (PasswordStrength.of(next) == PasswordStrengthLevel.weak) {
      errors[PasswordField.next] =
          'Too easy to guess. Add numbers, capitals or a symbol.';
    }
    if (confirm != next) {
      errors[PasswordField.confirm] = 'The passwords do not match.';
    }
    return PasswordValidation(errors);
  }

  /// Changes the password. Throws a [SettingsFailure] when the fields are
  /// invalid or the server refuses (for example a wrong current password).
  Future<void> call({
    required String current,
    required String next,
    required String confirm,
  }) async {
    if (!validate(current: current, next: next, confirm: confirm).isValid) {
      throw const SettingsFailure('Fix the highlighted fields and try again.');
    }
    final result = await _repository.changePassword(
      current: current,
      next: next,
    );
    if (!result.ok) {
      throw SettingsFailure(result.message ?? 'Could not change the password.');
    }
  }
}
