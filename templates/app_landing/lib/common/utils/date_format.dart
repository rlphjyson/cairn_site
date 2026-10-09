const List<String> _months = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Formats a date for display: `2026-09-14` -> `Sep 14, 2026`.
String formatDate(DateTime date) =>
    '${_months[date.month - 1]} ${date.day}, ${date.year}';

/// Formats a count for display: `120000` -> `120K`, `2400000` -> `2.4M`.
String formatCount(int count) {
  String trim(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
  if (count >= 1000000) return '${trim(count / 1000000)}M';
  if (count >= 1000) return '${trim(count / 1000)}K';
  return '$count';
}
