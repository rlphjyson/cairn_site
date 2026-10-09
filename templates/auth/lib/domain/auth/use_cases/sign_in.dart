import '../../validation/models/validation_issue.dart';
import '../../validation/use_cases/validate_email.dart';
import '../models/auth_failure.dart';
import '../models/session.dart';
import '../repositories/auth_repository.dart';

/// Signs in with an email and password.
///
/// The screen validates for inline errors first; this checks again so the rule
/// holds for any caller. Throws [AuthException] (invalid input, wrong
/// credentials, rate limited, offline...).
class SignIn {
  /// Creates the use case.
  const SignIn(this._repository, this._validateEmail);

  final AuthRepository _repository;
  final ValidateEmail _validateEmail;

  /// Runs it. The email is trimmed; the password is sent exactly as typed.
  Future<Session> call({
    required String email,
    required String password,
    bool remember = false,
  }) async {
    final ValidationIssue? emailIssue = _validateEmail(email);
    if (emailIssue != null) {
      throw AuthException(AuthFailure.invalidInput, issue: emailIssue);
    }
    if (password.isEmpty) {
      throw const AuthException(
        AuthFailure.invalidInput,
        issue: ValidationIssue.passwordRequired,
      );
    }
    return _repository.signIn(
      email: email.trim(),
      password: password,
      remember: remember,
    );
  }
}
