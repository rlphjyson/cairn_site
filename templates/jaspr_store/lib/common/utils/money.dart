/// Money is always an integer number of minor units (cents). Floats never touch
/// a price: 0.1 + 0.2 != 0.3 is not a property you want in a checkout.
library;

/// Formats [cents] as a localised-looking amount, e.g. `$1,234.50`.
///
/// Deliberately dependency-free (no `package:intl`): the formatting rules a
/// store actually needs fit in a few lines, and `intl` is large.
String formatMoney(int cents, {String currency = 'USD'}) {
  final negative = cents < 0;
  final abs = cents.abs();
  final whole = (abs ~/ 100).toString();
  final fraction = (abs % 100).toString().padLeft(2, '0');
  final grouped = _group(whole);
  final symbol = _symbols[currency] ?? '$currency ';
  return '${negative ? '-' : ''}$symbol$grouped.$fraction';
}

/// The plain decimal string used in structured data and Open Graph tags:
/// `1234.50`, never `$1,234.50`.
String decimalAmount(int cents) {
  final abs = cents.abs();
  return '${cents < 0 ? '-' : ''}${abs ~/ 100}.${(abs % 100).toString().padLeft(2, '0')}';
}

/// Percentage discount between [compareAt] and [price], rounded to a whole
/// percent. Returns 0 when there is no discount.
int discountPercent({required int price, int? compareAt}) {
  if (compareAt == null || compareAt <= price || compareAt <= 0) return 0;
  return (((compareAt - price) * 100) / compareAt).round();
}

/// Applies a percentage to an amount using integer arithmetic, rounding half up.
int percentOf(int cents, int percent) => ((cents * percent) + 50) ~/ 100;

String _group(String digits) {
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

const Map<String, String> _symbols = {'USD': r'$', 'EUR': '€', 'GBP': '£', 'CAD': r'CA$', 'AUD': r'A$'};
