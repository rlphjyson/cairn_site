import '../../../common/utils/luhn.dart';
import '../models/payment_details.dart';

/// The payment form's fields.
enum PaymentField {
  /// Name on the card.
  cardHolder,

  /// Card number.
  cardNumber,

  /// Expiry date.
  expiry,

  /// Security code.
  cvc,
}

/// Checks the demo payment form: name, a Luhn-valid number, an expiry that has
/// not passed and a 3 or 4 digit code.
///
/// Returns a message per invalid field; an empty map means the form is valid.
/// The clock is injected so expiry is testable.
class ValidatePaymentDetails {
  /// Creates the use case.
  const ValidatePaymentDetails([this._now = DateTime.now]);

  final DateTime Function() _now;

  /// Runs it.
  Map<PaymentField, String> call(PaymentDetails d) {
    final Map<PaymentField, String> errors = <PaymentField, String>{};
    if (d.cardHolder.trim().length < 2) {
      errors[PaymentField.cardHolder] = 'Enter the name on the card.';
    }
    final String digits = d.digits;
    if (digits.length < 13 || digits.length > 19 || !passesLuhn(digits)) {
      errors[PaymentField.cardNumber] = 'Enter a valid card number.';
    }
    final RegExpMatch? match = RegExp(
      r'^(0[1-9]|1[0-2])/(\d{2})$',
    ).firstMatch(d.expiry.trim());
    if (match == null) {
      errors[PaymentField.expiry] = 'Use the format MM/YY.';
    } else {
      final int month = int.parse(match.group(1)!);
      final int year = 2000 + int.parse(match.group(2)!);
      // A card is good through the last day of its expiry month.
      final DateTime lastGoodMoment = DateTime(year, month + 1);
      if (!_now().isBefore(lastGoodMoment)) {
        errors[PaymentField.expiry] = 'This card has expired.';
      }
    }
    if (!RegExp(r'^\d{3,4}$').hasMatch(d.cvc.trim())) {
      errors[PaymentField.cvc] = 'Enter the 3 or 4 digit code.';
    }
    return errors;
  }
}
