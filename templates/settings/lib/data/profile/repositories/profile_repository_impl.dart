import '../../../domain/profile/mappers/profile_mapper.dart';
import '../../../domain/profile/models/profile.dart';
import '../../../domain/profile/repositories/profile_repository.dart';
import '../../settings/remote/settings_data_source.dart';

/// Reads and writes the profile through a [SettingsDataSource].
class ProfileRepositoryImpl implements ProfileRepository {
  /// Creates the repository.
  const ProfileRepositoryImpl(this._source);

  final SettingsDataSource _source;

  @override
  Future<Profile> load() async =>
      ProfileMapper.fromJson(await _source.loadProfile());

  @override
  Future<Profile> save(Profile profile) async => ProfileMapper.fromJson(
    await _source.saveProfile(ProfileMapper.toJson(profile)),
  );

  @override
  Future<bool> isUsernameAvailable(String username) async =>
      ProfileMapper.availableFromJson(await _source.checkUsername(username));
}
