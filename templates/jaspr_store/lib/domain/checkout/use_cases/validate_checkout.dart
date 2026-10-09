library;

import '../../cart/models/cart.dart';
import '../models/checkout.dart';

final RegExp _email = RegExp(
  r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)+$",
);
final RegExp _phone = RegExp(r'^[0-9+()\-.\s]{7,20}$');

bool isValidEmail(String value) => value.length <= 254 && _email.hasMatch(value);

/// Patterns are deliberately forgiving about spacing and strict about shape.
final Map<String, RegExp> _postal = {
  'US': RegExp(r'^\d{5}(-\d{4})?$'),
  'CA': RegExp(r'^[A-Za-z]\d[A-Za-z][ -]?\d[A-Za-z]\d$'),
  'GB': RegExp(r'^[A-Za-z]{1,2}\d[A-Za-z\d]? ?\d[A-Za-z]{2}$'),
  'DE': RegExp(r'^\d{5}$'),
  'AU': RegExp(r'^\d{4}$'),
};

bool isValidPostalCode(String country, String value) => _postal[country]?.hasMatch(value) ?? false;

/// Pure validation. Returns a map of field name -> message; empty means valid.
/// Messages never echo the user's input back, so they are safe to render.
Map<String, String> validateCheckout(CheckoutForm f) {
  final e = <String, String>{};
  if (f.email.isEmpty) {
    e['email'] = 'Enter your email address.';
  } else if (!isValidEmail(f.email)) {
    e['email'] = 'Enter a valid email address, like name@example.com.';
  }
  if (f.fullName.length < 2) {
    e['fullName'] = 'Enter your full name.';
  } else if (f.fullName.length > 80) {
    e['fullName'] = 'That name is too long (80 characters maximum).';
  }
  if (f.phone.isNotEmpty && !_phone.hasMatch(f.phone)) {
    e['phone'] = 'Use digits, spaces and + ( ) - only (7 to 20 characters).';
  }
  if (f.address1.length < 3) {
    e['address1'] = 'Enter your street address.';
  } else if (f.address1.length > 100) {
    e['address1'] = 'That address line is too long (100 characters maximum).';
  }
  if (f.address2.length > 100) e['address2'] = 'That address line is too long (100 characters maximum).';
  if (f.city.length < 2) {
    e['city'] = 'Enter your city.';
  } else if (f.city.length > 60) {
    e['city'] = 'That city name is too long.';
  }
  final country = countryByCode(f.country);
  if (country == null) {
    e['country'] = 'Choose a country we ship to.';
  } else {
    if (f.region.length < 2) e['region'] = 'Enter your ${country.regionLabel.toLowerCase()}.';
    if (f.region.length > 60) e['region'] = 'That value is too long.';
    if (f.postalCode.isEmpty) {
      e['postalCode'] = 'Enter your ${country.postalLabel.toLowerCase()}.';
    } else if (!isValidPostalCode(country.code, f.postalCode)) {
      e['postalCode'] = 'That ${country.postalLabel.toLowerCase()} does not look right for ${country.name}.';
    }
  }
  if (DeliveryMethod.parse(f.delivery) == null) e['delivery'] = 'Choose a delivery method.';
  if (!f.acceptTerms) e['acceptTerms'] = 'Please confirm you understand this is a demo order.';
  return e;
}
