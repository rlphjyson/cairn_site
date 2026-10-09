import '../models/permission_kind.dart';
import '../models/permission_status.dart';

/// Asks the operating system for permissions.
///
/// The template never talks to the platform itself: the host injects an
/// implementation (see `doc/index.html` for one built on `permission_handler`).
/// The in-memory `DemoPermissionService` answers without a prompt.
abstract interface class PermissionService {
  /// The current status of [kind], without prompting.
  Future<PermissionStatus> status(PermissionKind kind);

  /// Prompts the user for [kind] and returns the answer.
  Future<PermissionStatus> request(PermissionKind kind);

  /// Opens the system settings page for the app. Offered after a refusal.
  Future<void> openSettings();
}
