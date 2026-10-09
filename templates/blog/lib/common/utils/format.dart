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

/// `Sep 18, 2026`. No `intl` dependency, so the template stays light.
String formatDate(DateTime date) =>
    '${_months[date.month - 1]} ${date.day}, ${date.year}';

/// `5 min read`.
String formatReadingTime(int minutes) => '$minutes min read';

/// The number of words in [text].
int wordCount(String text) =>
    text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;

/// Up to two initials for an avatar fallback.
String initials(String name) {
  final List<String> parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((String p) => p.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '';
  if (parts.length == 1) return parts.first[0].toUpperCase();
  return (parts.first[0] + parts.last[0]).toUpperCase();
}

/// [text] cut to [max] characters with an ellipsis.
String truncate(String text, int max) =>
    text.length <= max ? text : '${text.substring(0, max - 1).trimRight()}…';
