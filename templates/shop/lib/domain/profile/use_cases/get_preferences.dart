import '../models/preferences.dart';
import '../repositories/profile_repository.dart';

/// Loads the notification preferences.
class GetPreferences {
  /// Creates the use case.
  const GetPreferences(this._repository);

  final ProfileRepository _repository;

  /// Runs it.
  Future<Preferences> call() => _repository.getPreferences();
}
