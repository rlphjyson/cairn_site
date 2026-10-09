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

const List<String> _weekdays = <String>[
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
  'Sun',
];

/// `12 Oct 2026`.
String formatDate(DateTime date) =>
    '${date.day} ${_months[date.month - 1]} ${date.year}';

/// `Mon 12 Oct`.
String formatShortDate(DateTime date) =>
    '${_weekdays[date.weekday - 1]} ${date.day} ${_months[date.month - 1]}';

/// Adds [days] business days (Monday to Friday) to [from].
DateTime addBusinessDays(DateTime from, int days) {
  DateTime result = from;
  int left = days;
  while (left > 0) {
    result = result.add(const Duration(days: 1));
    if (result.weekday < DateTime.saturday) left--;
  }
  return result;
}
