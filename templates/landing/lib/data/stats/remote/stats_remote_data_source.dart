import '../../../common/utils/json.dart';

/// Reads the numbers band as decoded JSON.
abstract interface class StatsRemoteDataSource {
  /// The numbers band.
  Future<JsonMap> fetchStats();
}

/// The demo numbers. Values are plain strings so you control the formatting.
class InMemoryStatsRemoteDataSource implements StatsRemoteDataSource {
  /// Creates the data source.
  const InMemoryStatsRemoteDataSource();

  static const JsonMap _json = <String, Object?>{
    'title': 'Kestrel in numbers',
    'stats': <Object?>[
      <String, Object?>{
        'label': 'Teams on Kestrel',
        'value': '12,400',
        'description': 'In 90 countries',
      },
      <String, Object?>{
        'label': 'Tasks completed',
        'value': '48M',
        'description': 'And counting',
      },
      <String, Object?>{
        'label': 'Faster delivery',
        'value': '31%',
        'description': 'Median across customers',
      },
      <String, Object?>{
        'label': 'Uptime',
        'value': '99.98%',
        'description': 'Over the last 12 months',
      },
    ],
  };

  @override
  Future<JsonMap> fetchStats() async => _json;
}
