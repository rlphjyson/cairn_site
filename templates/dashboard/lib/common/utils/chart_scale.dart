import 'dart:math' as math;

/// Rounds [value] up to a "nice" axis maximum (1, 2, 2.5, 5 or 10 times a
/// power of ten), so grid lines land on readable numbers.
double niceCeil(double value) {
  if (value <= 0) return 1;
  final double magnitude = math
      .pow(10, (math.log(value) / math.ln10).floor())
      .toDouble();
  for (final double step in <double>[1, 2, 2.5, 5, 10]) {
    if (value <= step * magnitude) return step * magnitude;
  }
  return 10 * magnitude;
}
