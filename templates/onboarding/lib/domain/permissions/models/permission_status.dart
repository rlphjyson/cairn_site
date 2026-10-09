/// Where a permission stands.
enum PermissionStatus {
  /// Never asked.
  notDetermined,

  /// The user allowed it.
  granted,

  /// The user declined. Asking again may be possible.
  denied,

  /// The user declined and the system will not ask again; the only way back is
  /// the system settings.
  permanentlyDenied;

  /// Whether the permission is available.
  bool get isGranted => this == granted;

  /// Whether the user has declined it.
  bool get isDenied => this == denied || this == permanentlyDenied;

  /// The status stored under [key], or [notDetermined] when it is unknown.
  static PermissionStatus fromKey(String? key) {
    for (final PermissionStatus status in values) {
      if (status.name == key) return status;
    }
    return notDetermined;
  }
}
