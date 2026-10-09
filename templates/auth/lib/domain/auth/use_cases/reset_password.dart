import '../../validation/models/validation_issue.dart';
import '../../validation/use_cases/validate_password.dart';
import '../models/auth_failure.dart';
import '../models/reset_grant.dart';
import '../repositories/auth_repository.dart';

/// Sets a new password after the code was verified.
class ResetPassword {
  /// Creates the use case.
  const ResetPassword(this._repository, this._validatePassword);

  final AuthRepository _repository;
  final ValidatePassword _validatePassword;

  /// Runs it. Throws [AuthException] for invalid input, an expired grant or
  /// an offline server.
  Future<void> call({
    required ResetGrant grant,
    required String password,
    required String confirmation,
  }) async {
    final ValidationIssue? issue =
        _validatePassword(password) ??
        _validatePassword.confirm(password, confirmation);
    if (issue != null) {
      throw AuthException(AuthFailure.invalidInput, issue: issue);
    }
    return _repository.resetPassword(grant: grant, password: password);
  }
}
