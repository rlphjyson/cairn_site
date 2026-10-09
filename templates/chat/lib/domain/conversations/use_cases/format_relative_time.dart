import '../../../common/utils/dates.dart';

/// Turns a moment into the short text used in the conversation list and in
/// "last seen".
class FormatRelativeTime {
  /// Creates the use case.
  const FormatRelativeTime();

  /// `now`, `12m`, `3h` (the same day), `Yesterday`, `Mon` (this week),
  /// `7 Oct`, and `7 Oct 2025` for earlier years.
  String call(DateTime when, DateTime now) {
    final Duration elapsed = now.difference(when);
    if (elapsed < const Duration(minutes: 1)) return 'now';
    if (elapsed < const Duration(hours: 1)) return '${elapsed.inMinutes}m';
    final int days = calendarDaysBetween(when, now);
    if (days <= 0) return '${elapsed.inHours}h';
    if (days == 1) return 'Yesterday';
    if (days < 7) return weekdayShort(when);
    final String label = dayMonth(when);
    return when.year == now.year ? label : '$label ${when.year}';
  }

  /// `last seen just now`, `last seen 12m ago`, `last seen today at 14:05`,
  /// `last seen yesterday at 14:05`, `last seen Mon`, `last seen 7 Oct`.
  String lastSeen(DateTime when, DateTime now) {
    final Duration elapsed = now.difference(when);
    if (elapsed < const Duration(minutes: 1)) return 'last seen just now';
    if (elapsed < const Duration(hours: 1)) {
      return 'last seen ${elapsed.inMinutes}m ago';
    }
    final int days = calendarDaysBetween(when, now);
    if (days <= 0) return 'last seen today at ${formatClock(when)}';
    if (days == 1) return 'last seen yesterday at ${formatClock(when)}';
    return 'last seen ${call(when, now)}';
  }
}
