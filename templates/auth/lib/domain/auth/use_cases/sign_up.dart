import '../../validation/models/validation_issue.dart';
import '../../validation/use_cases/validate_email.dart';
import '../../validation/use_cases/validate_name.dart';
import '../../validation/use_cases/validate_password.dart';
import '../models/auth_failure.dart';
import '../models/session.dart';
import '../repositories/auth_repository.dart';

/// Creates an account.
///
/// Throws [AuthException]: invalid input, [AuthFailure.emailTaken], offline...
class SignUp {
  /// Creates the use case.
  const SignUp(
    this._repository,
    this._validateName,
    this._validateEmail,
    this._validatePassword,
  );

  final AuthRepository _repository;
  final ValidateName _validateName;
  final ValidateEmail _validateEmail;
  final ValidatePassword _validatePassword;

  /// Runs it.
  Future<Session> call({
    required String name,
    required String email,
    required String password,
    required String confirmation,
    required bool acceptedTerms,
  }) async {
    final ValidationIssue? issue =
        _validateName(name) ??
        _validateEmail(email) ??
        _validatePassword(password) ??
        _validatePassword.confirm(password, confirmation) ??
        (acceptedTerms ? null : ValidationIssue.termsRequired);
    if (issue != null) {
      throw AuthException(AuthFailure.invalidInput, issue: issue);
    }
    return _repository.signUp(
      name: name.trim(),
      email: email.trim(),
      password: password,
    );
  }
}
