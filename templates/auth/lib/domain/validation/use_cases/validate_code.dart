import '../../../common/constants/auth_policy.dart';
import '../models/validation_issue.dart';

/// Checks a one-time code is a full set of digits.
class ValidateCode {
  /// Creates the use case.
  const ValidateCode();

  static final RegExp _digits = RegExp(r'^\d+$');

  /// The issue with [code], or `null` when it is complete.
  ValidationIssue? call(String code) {
    final String value = code.trim();
    if (value.length != AuthPolicy.codeLength || !_digits.hasMatch(value)) {
      return ValidationIssue.codeIncomplete;
    }
    return null;
  }
}
