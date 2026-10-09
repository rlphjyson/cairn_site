import '../models/stats_content.dart';
import '../repositories/stats_repository.dart';

/// Loads the stats section's content.
class GetStats {
  /// Creates the use case.
  const GetStats(this._repository);

  final StatsRepository _repository;

  /// Runs the use case.
  Future<StatsContent> call() => _repository.getStats();
}
