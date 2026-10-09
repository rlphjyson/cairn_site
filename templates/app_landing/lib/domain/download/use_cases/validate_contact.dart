import '../models/send_outcome.dart';

/// Checks that text is an email address or a phone number.
///
/// Deliberately lenient. An email has one `@`, no spaces and a dot in the
/// domain. A phone number is anything with 7 to 15 digits once spaces, dots,
/// dashes and brackets are removed (the E.164 maximum is 15), with an optional
/// leading `+`. Real validation happens when the message is delivered.
class ValidateContact {
  /// Creates the use case.
  const ValidateContact();

  static final RegExp _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');
  static final RegExp _phoneChars = RegExp(r'^\+?[\d\s().\-]+$');

  /// Checks [value]; a valid result carries the normalised [Contact].
  ContactCheck call(String value) {
    final String text = value.trim();
    if (text.isEmpty) {
      return const ContactCheck.invalid(
        'Enter your email address or phone number.',
      );
    }
    if (text.contains('@')) {
      if (_email.hasMatch(text)) {
        return ContactCheck.valid(Contact(ContactKind.email, text));
      }
      return const ContactCheck.invalid(
        'That does not look like an email address.',
      );
    }
    if (_phoneChars.hasMatch(text)) {
      final String digits = text.replaceAll(RegExp(r'\D'), '');
      if (digits.length >= 7 && digits.length <= 15) {
        final String normalised = text.startsWith('+') ? '+$digits' : digits;
        return ContactCheck.valid(Contact(ContactKind.phone, normalised));
      }
      return const ContactCheck.invalid(
        'A phone number has 7 to 15 digits, for example +1 415 555 0134.',
      );
    }
    return const ContactCheck.invalid(
      'Enter an email address or a phone number.',
    );
  }
}
