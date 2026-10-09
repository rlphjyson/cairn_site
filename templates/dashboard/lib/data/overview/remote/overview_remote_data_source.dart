import 'dart:math' as math;

import 'series.dart';

/// Reads the overview figures as decoded JSON, as a REST client would.
abstract interface class OverviewRemoteDataSource {
  /// KPI objects for the named period (`week`, `month` or `year`).
  Future<List<Map<String, Object?>>> fetchKpis(String period);

  /// Revenue points for the named period.
  Future<List<Map<String, Object?>>> fetchRevenue(String period);
}

/// Deterministic demo data, shaped like a backend response.
class InMemoryOverviewRemoteDataSource implements OverviewRemoteDataSource {
  /// Creates the data source.
  const InMemoryOverviewRemoteDataSource();

  List<Map<String, Object?>> _revenue(String period) {
    final SeriesShape shape = SeriesShape.of(period);
    return <Map<String, Object?>>[
      for (int i = 0; i < shape.labels.length; i++)
        () {
          final double current =
              (shape.scale *
                      3400 *
                      (1 + 0.28 * math.sin(i * 1.1 + 0.5) + 0.05 * i))
                  .roundToDouble();
          final double previous = (current * (0.84 + 0.05 * math.cos(i * 1.7)))
              .roundToDouble();
          return <String, Object?>{
            'label': shape.labels[i],
            'current': current,
            'previous': previous,
          };
        }(),
    ];
  }

  @override
  Future<List<Map<String, Object?>>> fetchRevenue(String period) async =>
      _revenue(period);

  @override
  Future<List<Map<String, Object?>>> fetchKpis(String period) async {
    final SeriesShape shape = SeriesShape.of(period);
    final List<Map<String, Object?>> revenue = _revenue(period);
    final double current = revenue.fold(
      0,
      (double s, Map<String, Object?> p) => s + (p['current']! as double),
    );
    final double previous = revenue.fold(
      0,
      (double s, Map<String, Object?> p) => s + (p['previous']! as double),
    );
    return <Map<String, Object?>>[
      <String, Object?>{
        'id': 'revenue',
        'label': 'Total revenue',
        'value': current,
        'unit': 'currency',
        'delta': (current / previous - 1) * 100,
      },
      <String, Object?>{
        'id': 'subscriptions',
        'label': 'Subscriptions',
        'value': (shape.scale * 118).roundToDouble(),
        'unit': 'count',
        'delta': 8.2,
      },
      <String, Object?>{
        'id': 'sales',
        'label': 'Sales',
        'value': (shape.scale * 392).roundToDouble(),
        'unit': 'count',
        'delta': 3.1,
      },
      <String, Object?>{
        'id': 'refund-rate',
        'label': 'Refund rate',
        'value': 1.8,
        'unit': 'percent',
        'delta': -4.6,
        'lowerIsBetter': true,
      },
    ];
  }
}
