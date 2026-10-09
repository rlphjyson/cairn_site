import '../models/profile.dart';
import '../repositories/profile_repository.dart';

/// Loads the signed-in person's profile.
class GetProfile {
  /// Creates the use case.
  const GetProfile(this._repository);

  final ProfileRepository _repository;

  /// The profile.
  Future<Profile> call() => _repository.load();
}
