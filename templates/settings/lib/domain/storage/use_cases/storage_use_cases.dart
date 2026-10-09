import '../models/storage_usage.dart';
import '../repositories/storage_repository.dart';

/// Loads what the app stores on the device.
class GetStorageUsage {
  /// Creates the use case.
  const GetStorageUsage(this._repository);

  final StorageRepository _repository;

  /// The usage.
  Future<StorageUsage> call() => _repository.usage();
}

/// Empties the cache.
class ClearCache {
  /// Creates the use case.
  const ClearCache(this._repository);

  final StorageRepository _repository;

  /// Clears the cache and returns the bytes reclaimed. Saved content is never
  /// touched.
  Future<int> call() => _repository.clearCache();
}
