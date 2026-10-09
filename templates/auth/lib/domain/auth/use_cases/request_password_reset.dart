import '../../validation/models/validation_issue.dart';
import '../../validation/use_cases/validate_email.dart';
import '../models/auth_failure.dart';
import '../repositories/auth_repository.dart';

/// Asks for a password-reset code to be emailed.
///
/// Completes the same way whether or not an account exists for the address. A
/// different answer ("no such account") would let anyone test which emails are
/// registered, so the screen always says "if an account exists, we sent a
/// code".
class RequestPasswordReset {
  /// Creates the use case.
  const RequestPasswordReset(this._repository, this._validateEmail);

  final AuthRepository _repository;
  final ValidateEmail _validateEmail;

  /// Runs it.
  Future<void> call(String email) async {
    final ValidationIssue? issue = _validateEmail(email);
    if (issue != null) {
      throw AuthException(AuthFailure.invalidInput, issue: issue);
    }
    return _repository.requestPasswordReset(email.trim());
  }
}
