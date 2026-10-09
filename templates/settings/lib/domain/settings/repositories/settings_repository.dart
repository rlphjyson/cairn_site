import '../models/app_info.dart';
import '../models/settings_snapshot.dart';

/// Where setting values and app info come from.
abstract interface class SettingsRepository {
  /// Every stored value, repaired against the registry.
  Future<SettingsSnapshot> load();

  /// Persists [snapshot].
  Future<void> save(SettingsSnapshot snapshot);

  /// The app's name, version and licences.
  Future<AppInfo> appInfo();
}
