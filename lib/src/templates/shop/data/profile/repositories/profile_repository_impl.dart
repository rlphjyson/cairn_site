import '../../../domain/profile/models/account.dart';
import '../../../domain/profile/models/preferences.dart';
import '../../../domain/profile/repositories/profile_repository.dart';
import '../remote/profile_remote_data_source.dart';

/// [ProfileRepository] backed by a [ProfileRemoteDataSource].
class ProfileRepositoryImpl implements ProfileRepository {
  /// Creates the repository.
  ProfileRepositoryImpl(this._dataSource);

  final ProfileRemoteDataSource _dataSource;

  @override
  Future<Account> getAccount() async => _dataSource.readAccount();

  @override
  Future<Preferences> getPreferences() async => _dataSource.readPreferences();

  @override
  Future<Preferences> savePreferences(Preferences preferences) async {
    _dataSource.writePreferences(preferences);
    return preferences;
  }
}
