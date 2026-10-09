import 'dart:math' as math;

import '../../overview/remote/series.dart';

/// Reads the analytics figures as decoded JSON.
abstract interface class AnalyticsRemoteDataSource {
  /// Traffic sources for the named period.
  Future<List<Map<String, Object?>>> fetchTraffic(String period);

  /// Device breakdown for the named period.
  Future<List<Map<String, Object?>>> fetchDevices(String period);

  /// Visitors over time for the named period.
  Future<List<Map<String, Object?>>> fetchVisits(String period);

  /// The conversion figure for the named period.
  Future<Map<String, Object?>> fetchConversion(String period);
}

/// Deterministic demo data, shaped like a backend response.
class InMemoryAnalyticsRemoteDataSource implements AnalyticsRemoteDataSource {
  /// Creates the data source.
  const InMemoryAnalyticsRemoteDataSource();

  @override
  Future<List<Map<String, Object?>>> fetchTraffic(String period) async {
    final int shift = switch (period) {
      'week' => 0,
      'month' => 3,
      _ => 6,
    };
    final List<(String, double)> rows = <(String, double)>[
      ('Search', 38.0 - shift),
      ('Direct', 27.0 + shift / 2),
      ('Social', 17.0 + shift / 2),
      ('Referral', 11.0),
      ('Email', 7.0),
    ];
    return <Map<String, Object?>>[
      for (final (String, double) r in rows)
        <String, Object?>{'label': r.$1, 'share': r.$2},
    ];
  }

  @override
  Future<List<Map<String, Object?>>> fetchDevices(String period) async {
    final double scale = SeriesShape.of(period).scale;
    return <Map<String, Object?>>[
      <String, Object?>{'label': 'Desktop', 'sessions': (4200 * scale).round()},
      <String, Object?>{'label': 'Mobile', 'sessions': (5600 * scale).round()},
      <String, Object?>{'label': 'Tablet', 'sessions': (900 * scale).round()},
    ];
  }

  @override
  Future<List<Map<String, Object?>>> fetchVisits(String period) async {
    final SeriesShape shape = SeriesShape.of(period);
    return <Map<String, Object?>>[
      for (int i = 0; i < shape.labels.length; i++)
        () {
          final double visitors =
              (shape.scale *
                      1800 *
                      (1 + 0.22 * math.sin(i * 0.9 + 1) + 0.03 * i))
                  .roundToDouble();
          return <String, Object?>{
            'label': shape.labels[i],
            'visitors': visitors,
            'returning': (visitors * (0.42 + 0.06 * math.cos(i * 1.3)))
                .roundToDouble(),
          };
        }(),
    ];
  }

  @override
  Future<Map<String, Object?>> fetchConversion(String period) async =>
      <String, Object?>{
        'rate': switch (period) {
          'week' => 3.2,
          'month' => 3.4,
          _ => 3.7,
        },
        'target': 4.5,
      };
}
