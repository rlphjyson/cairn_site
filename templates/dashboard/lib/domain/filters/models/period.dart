/// The time range every chart and figure is calculated for.
enum Period {
  /// The last seven days, by day.
  week('7 days'),

  /// The last thirty days, in five-day steps.
  month('30 days'),

  /// The last twelve months, by month.
  year('12 months');

  const Period(this.label);

  /// Shown in the period picker.
  final String label;
}
