/// Describes when something last happened, relative to [now].
///
/// `Active now`, `Active 5 minutes ago`, `Active 3 hours ago`,
/// `Active 2 days ago`, `Active 3 weeks ago`.
String describeActivity(DateTime then, DateTime now) {
  final Duration gap = now.difference(then);
  if (gap.inMinutes < 1) return 'Active now';
  if (gap.inMinutes < 60) {
    return 'Active ${_plural(gap.inMinutes, 'minute')} ago';
  }
  if (gap.inHours < 24) return 'Active ${_plural(gap.inHours, 'hour')} ago';
  if (gap.inDays < 14) return 'Active ${_plural(gap.inDays, 'day')} ago';
  return 'Active ${_plural(gap.inDays ~/ 7, 'week')} ago';
}

String _plural(int n, String unit) {
  final String s = n == 1 ? '' : 's';
  return '$n $unit$s';
}
