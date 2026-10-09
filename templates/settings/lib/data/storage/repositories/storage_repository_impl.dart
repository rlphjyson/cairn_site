import '../../../domain/storage/mappers/storage_mapper.dart';
import '../../../domain/storage/models/storage_usage.dart';
import '../../../domain/storage/repositories/storage_repository.dart';
import '../../settings/remote/settings_data_source.dart';

/// Storage figures, through a [SettingsDataSource].
class StorageRepositoryImpl implements StorageRepository {
  /// Creates the repository.
  const StorageRepositoryImpl(this._source);

  final SettingsDataSource _source;

  @override
  Future<StorageUsage> usage() async =>
      StorageMapper.usageFromJson(await _source.loadStorage());

  @override
  Future<int> clearCache() async =>
      StorageMapper.reclaimedFromJson(await _source.clearCache());
}
