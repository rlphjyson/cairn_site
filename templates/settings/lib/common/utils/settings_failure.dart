/// Thrown by a use case when it cannot do what it was asked.
///
/// The [message] is written for the person using the app, so a view can show it
/// as it is.
class SettingsFailure implements Exception {
  /// Creates a failure.
  const SettingsFailure(this.message);

  /// What went wrong, in a sentence.
  final String message;

  @override
  String toString() => 'SettingsFailure: $message';
}
