/// A device permission the onboarding can ask for.
enum PermissionKind {
  /// Push notifications.
  notifications,

  /// The device's location.
  location,

  /// The camera.
  camera;

  /// The key used for this permission in JSON.
  String get key => name;

  /// The kind stored under [key], or `null` when it is unknown.
  static PermissionKind? fromKey(String? key) {
    for (final PermissionKind kind in values) {
      if (kind.key == key) return kind;
    }
    return null;
  }
}
