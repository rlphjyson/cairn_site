import '../../../domain/settings/mappers/settings_mapper.dart';
import '../../../domain/settings/models/app_info.dart';
import '../../../domain/settings/models/settings_snapshot.dart';
import '../../../domain/settings/repositories/settings_repository.dart';
import '../remote/settings_data_source.dart';

/// Reads and writes settings through a [SettingsDataSource].
class SettingsRepositoryImpl implements SettingsRepository {
  /// Creates the repository.
  const SettingsRepositoryImpl(this._source, this._mapper);

  final SettingsDataSource _source;
  final SettingsMapper _mapper;

  @override
  Future<SettingsSnapshot> load() async =>
      _mapper.snapshotFromJson(await _source.loadSettings());

  @override
  Future<void> save(SettingsSnapshot snapshot) =>
      _source.saveSettings(_mapper.snapshotToJson(snapshot));

  @override
  Future<AppInfo> appInfo() async =>
      _mapper.appInfoFromJson(await _source.loadAppInfo());
}
