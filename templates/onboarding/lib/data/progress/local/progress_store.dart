/// Local storage for the user's progress, as decoded JSON.
///
/// Anything that can keep a small JSON object fits: `shared_preferences`
/// (a string under one key), a file, a database row or a secure store.
/// `doc/index.html` shows the `shared_preferences` version.
abstract interface class ProgressStore {
  /// The saved object, or `null` when nothing is saved.
  Future<Map<String, Object?>?> read();

  /// Replaces the saved object.
  Future<void> write(Map<String, Object?> json);

  /// Forgets it.
  Future<void> clear();
}

/// Keeps progress in memory, for the life of the object.
///
/// Give the same instance to a second `OnboardingApp` to simulate the app being
/// closed and re-opened, which is how the tests exercise resuming.
class InMemoryProgressStore implements ProgressStore {
  /// Creates a store, optionally starting with [initial] saved.
  InMemoryProgressStore([Map<String, Object?>? initial]) : _json = initial;

  Map<String, Object?>? _json;

  @override
  Future<Map<String, Object?>?> read() async => _json;

  @override
  Future<void> write(Map<String, Object?> json) async => _json = json;

  @override
  Future<void> clear() async => _json = null;
}
