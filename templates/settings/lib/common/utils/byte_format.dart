/// Formats [bytes] for people: `0 B`, `812 KB`, `84 MB`, `1.8 GB`.
///
/// Units are powers of 1024. One decimal is kept below 100 units, and dropped
/// when it would be `.0`.
String formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  const List<String> units = <String>['KB', 'MB', 'GB', 'TB'];
  double value = bytes / 1024;
  int unit = 0;
  while (value >= 1024 && unit < units.length - 1) {
    value /= 1024;
    unit++;
  }
  final bool whole =
      value >= 100 || (value - value.roundToDouble()).abs() < 0.05;
  final String text = whole
      ? value.round().toString()
      : value.toStringAsFixed(1);
  return '$text ${units[unit]}';
}
