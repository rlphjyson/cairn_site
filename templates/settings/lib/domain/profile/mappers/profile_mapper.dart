import '../../../common/constants/avatar_presets.dart';
import '../models/profile.dart';

/// Turns decoded JSON into a [Profile] and back.
///
/// ```json
/// {
///   "name": "Ada Lovelace",
///   "username": "ada",
///   "email": "ada@example.com",
///   "bio": "Mathematician.",
///   "avatar": "initials"
/// }
/// ```
abstract final class ProfileMapper {
  /// The profile in [json]. An unknown avatar becomes the initials.
  static Profile fromJson(Map<String, Object?> json) {
    final String avatar = json['avatar'] as String? ?? AvatarPresets.initials;
    return Profile(
      name: json['name'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      avatarId: AvatarPresets.isValid(avatar) ? avatar : AvatarPresets.initials,
    );
  }

  /// The JSON for [profile].
  static Map<String, Object?> toJson(Profile profile) => <String, Object?>{
    'name': profile.name,
    'username': profile.username,
    'email': profile.email,
    'bio': profile.bio,
    'avatar': profile.avatarId,
  };

  /// The answer to a username lookup: `{ "available": true }`.
  static bool availableFromJson(Map<String, Object?> json) =>
      json['available'] == true;
}
