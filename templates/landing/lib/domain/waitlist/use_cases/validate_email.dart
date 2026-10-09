/// Checks that text looks like an email address.
///
/// Deliberately lenient: one `@`, no spaces, a dot in the domain. Real
/// validation happens when the service sends the confirmation message.
class ValidateEmail {
  /// Creates the use case.
  const ValidateEmail();

  static final RegExp _pattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

  /// The message to show, or `null` when [value] is acceptable.
  String? call(String value) {
    final String email = value.trim();
    if (email.isEmpty) return 'Enter your email address.';
    if (!_pattern.hasMatch(email)) {
      return 'That does not look like an email address.';
    }
    return null;
  }
}
