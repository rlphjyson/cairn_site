/// The x-axis labels and volume scale for each period, shared by the demo data
/// sources.
class SeriesShape {
  const SeriesShape._(this.labels, this.scale);

  /// Looks up the shape for a wire period name.
  factory SeriesShape.of(String period) => switch (period) {
    'week' => const SeriesShape._(<String>[
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ], 1),
    'month' => const SeriesShape._(<String>[
      '5',
      '10',
      '15',
      '20',
      '25',
      '30',
    ], 4.3),
    _ => const SeriesShape._(<String>[
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
    ], 52),
  };

  /// One label per point.
  final List<String> labels;

  /// Volume multiplier relative to a week.
  final double scale;
}
