import '../models/app_info.dart';
import '../repositories/settings_repository.dart';

/// Loads the app's version and licences.
class GetAppInfo {
  /// Creates the use case.
  const GetAppInfo(this._repository);

  final SettingsRepository _repository;

  /// The app info.
  Future<AppInfo> call() => _repository.appInfo();
}
