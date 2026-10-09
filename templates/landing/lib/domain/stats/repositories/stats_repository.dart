import '../models/stats_content.dart';

/// Where the stats section's content comes from.
abstract interface class StatsRepository {
  /// The section's content.
  Future<StatsContent> getStats();
}
