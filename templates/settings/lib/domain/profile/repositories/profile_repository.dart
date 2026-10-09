import '../models/profile.dart';

/// Where the signed-in person's profile lives.
abstract interface class ProfileRepository {
  /// The current profile.
  Future<Profile> load();

  /// Saves [profile] and returns what the server kept.
  Future<Profile> save(Profile profile);

  /// Whether [username] is free to take.
  Future<bool> isUsernameAvailable(String username);
}
