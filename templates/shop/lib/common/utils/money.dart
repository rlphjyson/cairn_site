/// Formats a dollar amount: whole numbers without cents, otherwise two places.
String formatMoney(double value) => value == value.roundToDouble()
    ? '\$${value.toInt()}'
    : '\$${value.toStringAsFixed(2)}';
