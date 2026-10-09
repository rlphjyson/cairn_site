import '../../../domain/profile/mappers/profile_mapper.dart';
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
  Future<Account?> getAccount() async {
    final Map<String, Object?>? json = _dataSource.readAccount();
    return json == null ? null : ProfileMapper.accountFromJson(json);
  }

  @override
  Future<Account> signIn() async =>
      ProfileMapper.accountFromJson(_dataSource.signIn());

  @override
  Future<void> signOut() async => _dataSource.signOut();

  @override
  Future<Preferences> getPreferences() async =>
      ProfileMapper.preferencesFromJson(_dataSource.readPreferences());

  @override
  Future<Preferences> savePreferences(Preferences preferences) async {
    _dataSource.writePreferences(ProfileMapper.preferencesToJson(preferences));
    return preferences;
  }
}
