import '../models/profile.dart';
import '../models/profile_validation.dart';

/// Checks a profile before it is saved. Pure: no I/O, no state.
class ValidateProfile {
  /// Creates the use case.
  const ValidateProfile();

  static final RegExp _username = RegExp(r'^[a-z0-9_.]+$');
  static final RegExp _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

  /// The shortest username allowed.
  static const int minUsername = 3;

  /// The longest username allowed.
  static const int maxUsername = 20;

  /// The first problem with [username], or `null` when the format is fine.
  static String? usernameProblem(String username) {
    final String u = username.trim();
    if (u.isEmpty) return 'Choose a username.';
    if (u.length < minUsername) {
      return 'Use at least $minUsername characters.';
    }
    if (u.length > maxUsername) {
      return 'Use $maxUsername characters or fewer.';
    }
    if (!_username.hasMatch(u)) {
      return 'Use lower case letters, numbers, dots and underscores.';
    }
    return null;
  }

  /// Every problem with [profile], by field.
  ProfileValidation call(Profile profile) {
    final Map<ProfileField, String> errors = <ProfileField, String>{};
    if (profile.name.trim().isEmpty) {
      errors[ProfileField.name] = 'Enter your name.';
    } else if (profile.name.trim().length > 50) {
      errors[ProfileField.name] = 'Use 50 characters or fewer.';
    }
    final String? username = usernameProblem(profile.username);
    if (username != null) errors[ProfileField.username] = username;
    if (profile.email.trim().isEmpty) {
      errors[ProfileField.email] = 'Enter your email.';
    } else if (!_email.hasMatch(profile.email.trim())) {
      errors[ProfileField.email] = 'Enter a valid email address.';
    }
    if (profile.bio.length > Profile.maxBioLength) {
      errors[ProfileField.bio] =
          'Keep it to ${Profile.maxBioLength} characters.';
    }
    return ProfileValidation(errors);
  }
}
