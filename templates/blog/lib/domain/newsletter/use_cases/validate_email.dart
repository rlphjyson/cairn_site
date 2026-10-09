/// Checks an email address the way a sign-up form should: strictly enough to
/// catch typos, loosely enough not to reject real addresses.
class ValidateEmail {
  /// Creates the use case.
  const ValidateEmail();

  static final RegExp _pattern = RegExp(
    r'^[^\s@]+@[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?'
    r'(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?)+$',
  );

  /// `null` when [email] is acceptable, otherwise a message for the field.
  String? call(String email) {
    final String value = email.trim();
    if (value.isEmpty) return 'Enter your email address.';
    if (value.length > 254 || !_pattern.hasMatch(value)) {
      return 'That does not look like an email address.';
    }
    return null;
  }
}
