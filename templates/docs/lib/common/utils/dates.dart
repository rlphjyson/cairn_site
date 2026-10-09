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

/// Formats [date] as `Mar 4, 2026`, with no locale data needed.
String formatDate(DateTime date) =>
    '${_months[date.month - 1]} ${date.day}, ${date.year}';
