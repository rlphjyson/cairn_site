import '../models/settings_snapshot.dart';
import '../repositories/settings_repository.dart';

/// Loads every stored setting value.
class LoadSettings {
  /// Creates the use case.
  const LoadSettings(this._repository);

  final SettingsRepository _repository;

  /// The stored values, with defaults for anything missing.
  Future<SettingsSnapshot> call() => _repository.load();
}
