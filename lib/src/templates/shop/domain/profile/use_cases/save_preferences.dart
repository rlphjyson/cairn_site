import '../models/preferences.dart';
import '../repositories/profile_repository.dart';

/// Stores the notification preferences.
class SavePreferences {
  /// Creates the use case.
  const SavePreferences(this._repository);

  final ProfileRepository _repository;

  /// Runs it.
  Future<Preferences> call(Preferences preferences) =>
      _repository.savePreferences(preferences);
}
