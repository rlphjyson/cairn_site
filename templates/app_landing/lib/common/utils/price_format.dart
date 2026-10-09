/// Formats a price for display: `12` -> `$12`, `9.6` -> `$9.60`.
String formatPrice(double amount, {String currency = r'$'}) {
  final bool whole = amount == amount.roundToDouble();
  return '$currency${whole ? amount.toStringAsFixed(0) : amount.toStringAsFixed(2)}';
}
