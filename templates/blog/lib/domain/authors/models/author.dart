import 'package:equatable/equatable.dart';

/// Someone who writes on the blog.
class Author extends Equatable {
  /// Creates an author.
  const Author({
    required this.id,
    required this.name,
    required this.role,
    required this.bio,
    required this.avatar,
  });

  /// Stable identifier, referenced by posts.
  final String id;

  /// Display name.
  final String name;

  /// Job title.
  final String role;

  /// A sentence or two about them.
  final String bio;

  /// Bundled asset path or an `http(s)` URL.
  final String avatar;

  @override
  List<Object?> get props => <Object?>[id, name, role, bio, avatar];
}

/// An [Author] with how much they have published.
class AuthorProfile extends Equatable {
  /// Creates a profile.
  const AuthorProfile({required this.author, required this.postCount});

  /// The author.
  final Author author;

  /// Published posts.
  final int postCount;

  @override
  List<Object?> get props => <Object?>[author, postCount];
}
