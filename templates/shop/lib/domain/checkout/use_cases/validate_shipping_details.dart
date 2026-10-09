import '../../orders/models/shipping_details.dart';

/// The shipping form's fields.
enum ShippingField {
  /// Recipient name.
  fullName,

  /// Contact email.
  email,

  /// Contact phone.
  phone,

  /// Street address.
  address,

  /// Town or city.
  city,

  /// Postal code.
  postalCode,
}

/// Checks the shipping form.
///
/// Returns a message per invalid field; an empty map means the form is valid.
class ValidateShippingDetails {
  /// Creates the use case.
  const ValidateShippingDetails();

  /// Runs it.
  Map<ShippingField, String> call(ShippingDetails d) {
    final Map<ShippingField, String> errors = <ShippingField, String>{};
    if (d.fullName.trim().length < 2) {
      errors[ShippingField.fullName] = 'Enter your full name.';
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$').hasMatch(d.email.trim())) {
      errors[ShippingField.email] = 'Enter a valid email address.';
    }
    final int phoneDigits = d.phone.replaceAll(RegExp(r'\D'), '').length;
    if (phoneDigits < 7 ||
        phoneDigits > 15 ||
        !RegExp(r'^[0-9+()\-\s.]+$').hasMatch(d.phone.trim())) {
      errors[ShippingField.phone] = 'Enter a valid phone number.';
    }
    if (d.address.trim().length < 5) {
      errors[ShippingField.address] = 'Enter your street address.';
    }
    if (d.city.trim().length < 2) {
      errors[ShippingField.city] = 'Enter your city.';
    }
    if (!RegExp(
      r'^[A-Za-z0-9][A-Za-z0-9\s\-]{1,8}[A-Za-z0-9]$',
    ).hasMatch(d.postalCode.trim())) {
      errors[ShippingField.postalCode] = 'Enter a valid postal code.';
    }
    return errors;
  }
}
