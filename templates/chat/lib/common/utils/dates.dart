const List<String> _weekdays = <String>[
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
  'Sun',
];

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

/// Midnight at the start of [value]'s day.
DateTime startOfDay(DateTime value) =>
    DateTime(value.year, value.month, value.day);

/// Whether [a] and [b] fall on the same calendar day.
bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Calendar days from [from] to [to] (negative when [to] is earlier).
///
/// Counts whole calendar days, so it is not thrown by daylight saving.
int calendarDaysBetween(DateTime from, DateTime to) => DateTime.utc(
  to.year,
  to.month,
  to.day,
).difference(DateTime.utc(from.year, from.month, from.day)).inDays;

String _two(int value) => value.toString().padLeft(2, '0');

/// `14:05`, in 24-hour time.
String formatClock(DateTime time) => '${_two(time.hour)}:${_two(time.minute)}';

/// `Mon`.
String weekdayShort(DateTime date) => _weekdays[date.weekday - 1];

/// `7 Oct`.
String dayMonth(DateTime date) => '${date.day} ${_months[date.month - 1]}';

/// The label of a date separator in a thread: `Today`, `Yesterday` or
/// `Mon 7 Oct` (with the year when it is not this year).
String formatDayLabel(DateTime day, DateTime now) {
  final int ago = calendarDaysBetween(day, now);
  if (ago == 0) return 'Today';
  if (ago == 1) return 'Yesterday';
  final String label = '${weekdayShort(day)} ${dayMonth(day)}';
  return day.year == now.year ? label : '$label ${day.year}';
}
