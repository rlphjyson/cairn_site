import '../../../common/constants/auth_policy.dart';
import '../models/validation_issue.dart';

/// Checks a display name.
class ValidateName {
  /// Creates the use case.
  const ValidateName();

  /// The issue with [name], or `null` when it is acceptable.
  ValidationIssue? call(String name) {
    final String value = name.trim();
    if (value.isEmpty) return ValidationIssue.nameRequired;
    if (value.length < AuthPolicy.minNameLength) {
      return ValidationIssue.nameTooShort;
    }
    return null;
  }
}
