/// Whether the operating system lets the app send notifications.
///
/// This is the system's decision, not a setting, so the host passes it in
/// (from `permission_handler` or similar) and the Notifications screen reacts.
enum NotificationPermission {
  /// Allowed.
  granted,

  /// The person refused. The app cannot ask again; they must change it in the
  /// system settings.
  denied,

  /// Not asked yet.
  notDetermined,
}
