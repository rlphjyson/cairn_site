import '../models/storage_usage.dart';

/// What the app stores on the device.
abstract interface class StorageRepository {
  /// The current usage.
  Future<StorageUsage> usage();

  /// Empties the cache and returns how many bytes that freed.
  Future<int> clearCache();
}
