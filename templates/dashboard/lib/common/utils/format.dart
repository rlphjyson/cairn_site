/// Number formatting for the dashboard.
abstract final class DashboardFormat {
  /// `31200` -> `31,200`.
  static String number(num value) {
    final String digits = value.round().abs().toString();
    final StringBuffer out = StringBuffer(value < 0 ? '-' : '');
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) out.write(',');
      out.write(digits[i]);
    }
    return out.toString();
  }

  /// `31200` -> `$31,200`.
  static String currency(num value) => '\$${number(value)}';

  /// `31200` -> `31.2k`, `950` -> `950`. For chart axes.
  static String compact(num value) {
    if (value.abs() >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }
    if (value.abs() >= 1000) {
      final double k = value / 1000;
      return '${k == k.roundToDouble() ? k.toInt() : k.toStringAsFixed(1)}k';
    }
    return value.round().toString();
  }

  /// `3.24` -> `3.2%`.
  static String percent(num value, {int decimals = 1}) =>
      '${value.toStringAsFixed(decimals)}%';

  /// `12.5` -> `+12.5%`, `-3` -> `-3.0%`.
  static String signedPercent(num value) =>
      '${value >= 0 ? '+' : ''}${value.toStringAsFixed(1)}%';
}
