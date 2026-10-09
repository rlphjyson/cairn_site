import '../models/permission_kind.dart';
import '../models/permission_status.dart';
import '../repositories/permission_service.dart';

/// Asks for one permission.
///
/// A platform failure (a missing plugin, a revoked entitlement) must never trap
/// the user in onboarding, so it is reported as [PermissionStatus.denied].
class RequestPermission {
  /// Creates the use case.
  const RequestPermission(this._service);

  final PermissionService _service;

  /// Runs it.
  Future<PermissionStatus> call(PermissionKind kind) async {
    try {
      final PermissionStatus status = await _service.request(kind);
      return status == PermissionStatus.notDetermined
          ? PermissionStatus.denied
          : status;
    } on Object {
      return PermissionStatus.denied;
    }
  }
}
