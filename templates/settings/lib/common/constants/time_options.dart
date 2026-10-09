/// Half-hour times of day, as `HH:mm`, for quiet hours.
abstract final class TimeOptions {
  /// `00:00`, `00:30`, ... `23:30`.
  static final List<String> halfHours = <String>[
    for (int h = 0; h < 24; h++) ...<String>[
      '${h.toString().padLeft(2, '0')}:00',
      '${h.toString().padLeft(2, '0')}:30',
    ],
  ];
}
