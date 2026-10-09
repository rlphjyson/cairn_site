import '../../validation/models/validation_issue.dart';
import '../../validation/use_cases/validate_code.dart';
import '../models/auth_failure.dart';
import '../models/reset_grant.dart';
import '../repositories/auth_repository.dart';

/// Checks the code from the email.
///
/// Throws [AuthException]: [AuthFailure.invalidCode] (with the attempts left),
/// [AuthFailure.codeExpired], [AuthFailure.tooManyAttempts]...
class VerifyCode {
  /// Creates the use case.
  const VerifyCode(this._repository, this._validateCode);

  final AuthRepository _repository;
  final ValidateCode _validateCode;

  /// Runs it.
  Future<ResetGrant> call({required String email, required String code}) async {
    final ValidationIssue? issue = _validateCode(code);
    if (issue != null) {
      throw AuthException(AuthFailure.invalidInput, issue: issue);
    }
    return _repository.verifyCode(email: email.trim(), code: code.trim());
  }
}
