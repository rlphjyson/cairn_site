import '../repositories/permission_service.dart';

/// Opens the system settings page, where a refused permission can be turned on.
class OpenPermissionSettings {
  /// Creates the use case.
  const OpenPermissionSettings(this._service);

  final PermissionService _service;

  /// Runs it. Failures are ignored: there is nothing more the user can do from
  /// here.
  Future<void> call() async {
    try {
      await _service.openSettings();
    } on Object {
      return;
    }
  }
}
