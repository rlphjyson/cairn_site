import '../../../common/utils/settings_failure.dart';
import '../models/profile.dart';
import '../repositories/profile_repository.dart';
import 'validate_profile.dart';

/// Validates a profile and, when it is valid, saves it.
class SaveProfile {
  /// Creates the use case.
  const SaveProfile(this._validate, this._repository);

  final ValidateProfile _validate;
  final ProfileRepository _repository;

  /// Saves [profile] and returns what was stored. Throws a [SettingsFailure]
  /// when it is invalid, or when [username] is taken.
  Future<Profile> call(Profile profile, {required String savedUsername}) async {
    if (!_validate(profile).isValid) {
      throw const SettingsFailure('Fix the highlighted fields and try again.');
    }
    final String username = profile.username.trim();
    if (username != savedUsername &&
        !await _repository.isUsernameAvailable(username)) {
      throw SettingsFailure('@$username is taken.');
    }
    return _repository.save(
      profile.copyWith(
        name: profile.name.trim(),
        username: username,
        email: profile.email.trim(),
        bio: profile.bio.trim(),
      ),
    );
  }
}
