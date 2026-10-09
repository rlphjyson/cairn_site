/// Example values in the formats the Language and region screen offers, so a
/// change is visible before it is saved.
///
/// A real app formats with `intl`; this only needs a fixed sample (31 December
/// 2026, 14:30, a 5 km run).
abstract final class FormatPreview {
  /// The sample date for a `dateFormat` id (`mdy`, `dmy` or `ymd`).
  static String date(String format) => switch (format) {
    'dmy' => '31/12/2026',
    'ymd' => '2026-12-31',
    _ => '12/31/2026',
  };

  /// The sample time for a `timeFormat` id (`12h` or `24h`).
  static String time(String format) => format == '24h' ? '14:30' : '2:30 PM';

  /// The sample distance for a `units` id (`metric` or `imperial`).
  static String distance(String units) =>
      units == 'imperial' ? '3.1 mi' : '5.0 km';

  /// The sample temperature for a `units` id.
  static String temperature(String units) =>
      units == 'imperial' ? '70 F' : '21 C';
}
