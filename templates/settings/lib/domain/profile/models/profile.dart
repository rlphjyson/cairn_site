import 'package:equatable/equatable.dart';

import '../../../common/constants/avatar_presets.dart';

/// The signed-in person's public details.
class Profile extends Equatable {
  /// Creates a profile.
  const Profile({
    required this.name,
    required this.username,
    required this.email,
    this.bio = '',
    this.avatarId = AvatarPresets.initials,
  });

  /// The display name.
  final String name;

  /// The unique handle, without the `@`.
  final String username;

  /// The sign-in email.
  final String email;

  /// A short description, up to [maxBioLength] characters.
  final String bio;

  /// One of [AvatarPresets].
  final String avatarId;

  /// The longest bio allowed.
  static const int maxBioLength = 160;

  /// The first letters of the first two words of [name], upper case.
  String get initials {
    final List<String> words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((String w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return '?';
    final String first = words.first[0];
    final String second = words.length > 1 ? words[1][0] : '';
    return (first + second).toUpperCase();
  }

  /// A copy with some fields changed.
  Profile copyWith({
    String? name,
    String? username,
    String? email,
    String? bio,
    String? avatarId,
  }) => Profile(
    name: name ?? this.name,
    username: username ?? this.username,
    email: email ?? this.email,
    bio: bio ?? this.bio,
    avatarId: avatarId ?? this.avatarId,
  );

  @override
  List<Object?> get props => <Object?>[name, username, email, bio, avatarId];
}
