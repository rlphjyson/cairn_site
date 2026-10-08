import '../../../domain/saved/repositories/saved_repository.dart';
import '../remote/saved_remote_data_source.dart';

/// [SavedRepository] backed by a [SavedRemoteDataSource].
class SavedRepositoryImpl implements SavedRepository {
  /// Creates the repository.
  SavedRepositoryImpl(this._dataSource);

  final SavedRemoteDataSource _dataSource;

  @override
  Future<Set<String>> getSavedIds() async => _dataSource.read();

  @override
  Future<Set<String>> toggle(String id) async {
    final Set<String> ids = _dataSource.read();
    if (!ids.remove(id)) ids.add(id);
    _dataSource.write(ids);
    return ids;
  }
}
