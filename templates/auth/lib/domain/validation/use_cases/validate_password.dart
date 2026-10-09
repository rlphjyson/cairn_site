import '../models/password_assessment.dart';
import '../models/validation_issue.dart';
import 'password_strength.dart';

/// Checks a *new* password against the policy.
///
/// Used when choosing a password (sign up, reset). Signing in only needs the
/// field to be non-empty: an older account may predate today's policy and must
/// still be able to get in.
class ValidatePassword {
  /// Creates the use case.
  const ValidatePassword(this._strength);

  final PasswordStrength _strength;

  /// The issue with [password], or `null` when it is acceptable.
  ValidationIssue? call(String password) {
    if (password.isEmpty) return ValidationIssue.passwordRequired;
    final PasswordAssessment assessment = _strength(password);
    if (!assessment.met.contains(PasswordRule.minLength)) {
      return ValidationIssue.passwordTooShort;
    }
    if (assessment.isCommon) return ValidationIssue.passwordTooCommon;
    if (!assessment.meetsPolicy) return ValidationIssue.passwordTooWeak;
    return null;
  }

  /// The issue with [confirmation] against [password], or `null` when they
  /// match.
  ValidationIssue? confirm(String password, String confirmation) {
    if (confirmation.isEmpty) return ValidationIssue.confirmationRequired;
    if (confirmation != password) return ValidationIssue.confirmationMismatch;
    return null;
  }
}
