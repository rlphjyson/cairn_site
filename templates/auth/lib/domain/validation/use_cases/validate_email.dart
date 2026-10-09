import '../models/validation_issue.dart';

/// Checks an email address.
///
/// Deliberately lenient: one `@`, something either side, a dot in the domain.
/// The only real proof an address works is sending mail to it, so the server
/// confirms ownership; this just catches typos early.
class ValidateEmail {
  /// Creates the use case.
  const ValidateEmail();

  static final RegExp _shape = RegExp(r'^[^\s@]+@[^\s@.]+(\.[^\s@.]+)+$');

  /// The issue with [email], or `null` when it is acceptable.
  ValidationIssue? call(String email) {
    final String value = email.trim();
    if (value.isEmpty) return ValidationIssue.emailRequired;
    if (value.length > 254 || !_shape.hasMatch(value)) {
      return ValidationIssue.emailInvalid;
    }
    return null;
  }
}
